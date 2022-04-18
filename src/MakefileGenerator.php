 <?php

use Composer\Composer;
use Composer\DependencyResolver\Operation\InstallOperation;
use Composer\DependencyResolver\Operation\UpdateOperation;
use Composer\EventDispatcher\EventSubscriberInterface;
use Composer\Installer\PackageEvent;
use Composer\Installer\PackageEvents;
use Composer\IO\IOInterface;
use Composer\Plugin\PluginInterface;

class MakefileGenerator implements PluginInterface, EventSubscriberInterface
{
    const CONFIG_FILE = 'makefile-generator.json';
    const PACKAGE_NAME = 'oussaka/makefile-generator';
    const FILE_NAME = 'Makefile';
    const SEP_BLOCK_START = '###> PHP-MAKEFILE-GENERATOR START %s ###';
    const SEP_BLOCK_END = '###< PHP-MAKEFILE-GENERATOR END %s ###';

    /**
     * @var Composer|null
     */
    protected $composer;

    /**
     * @var IOInterface|null
     */
    protected $io;

    public function __construct()
    {
        $this->io = new \Composer\IO\NullIO();
    }

    /**
     * Attach package installation events:.
     *
     * {@inheritdoc}
     */
    public static function getSubscribedEvents()
    {
        return [
            PackageEvents::POST_PACKAGE_INSTALL => 'regenerate',
            PackageEvents::POST_PACKAGE_UPDATE => 'regenerate',
            PackageEvents::POST_PACKAGE_UNINSTALL => 'uninstall',
        ];
    }

    /**
     * @param PackageEvent $e
     */
    public function regenerate(PackageEvent $e)
    {
        $operation = $e->getOperation();

        if ($operation instanceof InstallOperation && self::PACKAGE_NAME !== $operation->getPackage()->getName()) {
            return;
        }

        if ($operation instanceof UpdateOperation
            && !in_array(self::PACKAGE_NAME, [
                    $operation->getInitialPackage()->getName(),
                    $operation->getTargetPackage()->getName(),
                ]
            )
        ) {
            return;
        }

        $this->integration();
    }

    /**
     * Prepare the plugin to be uninstalled
     *
     * This will be called after deactivate.
     *
     * @param Composer    $composer
     * @param IOInterface $io
     *
     * @return void
     */
    public function uninstall(Composer $composer, IOInterface $io)
    {
        $makefileContents = $this->resetAutogenerated($this->getMakefileContents());
        $this->writeMakefile($makefileContents);
    }

    /**
     * Apply plugin modifications to Composer
     *
     * @param Composer    $composer
     * @param IOInterface $io
     *
     * @return void
     */
    public function activate(Composer $composer, IOInterface $io)
    {
        $this->composer = $composer;
        $this->io = $io;
    }

    /**
     * Remove any hooks from Composer
     *
     * This will be called when a plugin is deactivated before being
     * uninstalled, but also before it gets upgraded to a new version
     * so the old one can be deactivated and the new one activated.
     *
     * @param Composer    $composer
     * @param IOInterface $io
     *
     * @return void
     */
    public function deactivate(Composer $composer, IOInterface $io)
    {
        // $this->composer = $composer;
        // $this->io = $io;
    }

    public function integration()
    {
        $this->io->write($initialMessage = 'Generating Makefile ...', false);

        $rows = ['base'];

        if (is_dir('.git')) {
            $rows[] = 'git';
        }

        if (file_exists('docker-compose.yml') || file_exists('docker-compose.yaml')) {
            $rows[] = 'docker';
        }

        if (file_exists('composer.json')) {
            $rows[] = 'composer';
        }

        if (file_exists('phpunit.xml.dist')) {
            $rows[] = 'phpunit';
        }

        if (file_exists('behat.yml.dist') || file_exists('behat.yaml.dist')) {
            $rows[] = 'behat';
        }

        if (file_exists('package-lock.json')) {
            $rows[] = 'npm';
        }

        if (file_exists('yarn.lock')) {
            $rows[] = 'yarn';
        }

        if (file_exists('gulpfile.js')) {
            $rows[] = 'gulp';
        }

        if (file_exists('webpack.config.js')) {
            $rows[] = 'webpack';
        }

        if (file_exists('bower.json')) {
            $rows[] = 'bower';
        }

        if (file_exists('symfony.lock') || file_exists('bin/console')) {
            $rows[] = 'symfony-base';
        }

        if (file_exists('codeception.yml') || file_exists('codeception.yaml')) {
            $rows[] = 'codeception';
        }

        $conf = $this->getConf();
        if (!empty($conf['exclude']) && is_array($conf['exclude'])) {
            $rows = array_diff($rows, $conf['exclude']);
        }

        if (!empty($conf['include']) && is_array($conf['include'])) {
            $rows = array_merge($rows, array_filter($conf['include'], 'is_scalar'));
            $rows = array_unique($rows);
        }

        $this->buildBlock($rows);

        $this->io->overwrite($initialMessage.' Done.', true, strlen($initialMessage));
    }

    /**
     * @param string $makefileContents
     *
     * @return string
     */
    private function resetAutogenerated(string $makefileContents): string
    {
        $blockStart = $this->regexify(self::SEP_BLOCK_START, '/', false);
        $blockEnd = $this->regexify(self::SEP_BLOCK_END, '/', false);

        return preg_replace(
            "/\s*{$blockStart}.*{$blockEnd}/s",
            '',
            $makefileContents
        );
    }

    /**
     * @param string $string
     * @param string $delimiter
     * @param bool   $includeDelimiters
     *
     * @return string
     */
    private function regexify(string $string, string $delimiter = '/', bool $includeDelimiters = true): string
    {
        if ($delimiter) {
            $quoted = preg_quote($string, $delimiter);
        } else {
            $quoted = $string;
        }

        $replaced = str_replace('%s', '([^ ]+)', $quoted);

        if (!$includeDelimiters) {
            return $replaced;
        }

        return $delimiter.$replaced.$delimiter;
    }

    /**
     * @return string
     */
    private function getMakefileContents(): string
    {
        if (!file_exists(self::FILE_NAME)) {
            return '';
        }

        return file_get_contents(self::FILE_NAME);
    }

    /**
     * @param array $rows
     */
    private function buildBlock(array $rows)
    {
        $makefileContents = $this->resetAutogenerated($this->getMakefileContents());

        foreach ($rows as $row) {
            $makefileContents = $this->buildRow($makefileContents, $row);
        }

        $this->writeMakefile($makefileContents);
    }

    /**
     * @param string $makefileContents
     * @param string $name
     *
     * @return string
     */
    private function buildRow(string $makefileContents, string $name): string
    {
        $block = PHP_EOL
            .sprintf(self::SEP_BLOCK_START, $name).PHP_EOL
            .trim(file_get_contents(__DIR__.'/../makefiles/'.$name.'.mk'))
            .PHP_EOL
            .sprintf(self::SEP_BLOCK_END, $name)
            .PHP_EOL;

        $makefileContents .= $block;

        return $makefileContents;
    }

    /**
     * @param string $contents
     *
     * @return bool|int
     */
    private function writeMakefile(string $contents)
    {
        return file_put_contents(self::FILE_NAME, $contents);
    }

    /**
     * @return array
     */
    private function getConf(): array
    {
        if (!file_exists(self::CONFIG_FILE)) {
            return [];
        }

        $res = \json_decode(file_get_contents(self::CONFIG_FILE), true);

        if (empty($res) || !is_array($res)) {
            return [];
        }

        return $res;
    }
}
