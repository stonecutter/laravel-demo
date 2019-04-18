# laravel-demo

[![CircleCI](https://circleci.com/gh/stonecutter/laravel-demo.svg?style=svg)](https://circleci.com/gh/stonecutter/laravel-demo)

## 配置开发环境（以Ubuntu 18.10为例）

### 安装Apache、MySQL、PHP和Redis

- 安装Apache：

```
sudo apt install apache2
a2enmod rewrite
sudo service apache2 restart
```

- 安装PHP：

```
sudo apt install php7.2 php7.2-mbstring php7.2-xml php7.2-curl php7.2-mysql
```

- 安装MySQL：

```
sudo apt install mysql-server mysql-client
```

- 安装Redis：

```
sudo apt install redis-server
```

### 安装nodejs和npm：

```
sudo apt install nodejs npm
```

注意：npm禁止设置为淘宝加速，会改变`package-lock.json`中的组件下载地址，导致国外构建上线时下载缓慢。  

### 安装Composer

```
php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
```

- 配置中国镜像：Composer镜像不会改变`composer.lock`中的下载地址，可放心使用

```
composer config -g repo.packagist composer https://packagist.laravel-china.org
```

### 安装扩展包依赖

```
composer install
npm install
npm run dev
```

### 生成配置文件并修改环境变量

- 生成`.env`和秘钥

```
cp .env.example .env
php artisan key:generate
```

- 配置环境变量

```
DB_DATABASE=xxx_local
DB_USERNAME=username
DB_PASSWORD=password
```

- 手动建库

```
mysql -uroot -p
create database xxx_local;
```

- 运行测试

```
./phpunit.sh
./vendor/bin/phpunit tests/Unit/ExampleTest.php --filter testBasicTest
```

### 通过建立软连接来配置本地路径

```
sudo ln -s /config/apache2/site-available/laravel.conf /etc/apache2/sites-enabled
sudo ln -s $(pwd) /var/www/laravel-demo
```

### HTTP访问项目

```
curl http://laravel-demo.localhost
```

或者

```
google-chrome http://laravel-demo.localhost
```

## 开发流程

Github Flow: https://www.ruanyifeng.com/blog/2015/12/git-workflow.html

Closing issues using keywords: https://help.github.com/articles/closing-issues-via-commit-messages/

语义化版本: http://semver.org/lang/zh-CN/

### GitHub issue flow

```
# create issue on github.com, get issue ID xxx
git checkout -b issue-xxx
# coding
# testing
git add Foo.php FooTest.php
git commit -m 'new/fix: feature/bug detail. close #xxx'
git push origin issue-xxx
# CI(lint, test)
# New pull request
# review by other body
# merge to master
# CD(docker build lastest)
# 如果有问题，则在issue里评论并打开
git checkout -b issue-xxx-1
...
git commit -m 'fix: bug detail. close #xxx'
...
# 如果再有问题，增加最后的数字
git checkout -b issue-xxx-2
```

## 上线生产环境

```
git tag -a 1.2.3 -m 'fix: a bug'
git push --tags
# CD(docker build tag)
```

## 修改开源package

方法：做补丁 并且 贡献到开源项目。

patches越来越多，一旦开源项目升级，patch就会失效，需要重新定位行数，维护成本很高，所以一定要贡献到开源项目里，下次升级就可以删除patch了。

```
# fork org/package stonecutter/package
git clone stonecutter/package
cd package
# checkout last tag
git checkout 1.2.3
# coding
```

### 做补丁

```
diff -uN ../project/vendor/org/package/Foo.php Foo.php > ../project/patches/Y_m_d_His_repo_something.patch
diff -uN ../project/vendor/org/package/Bar.php Bar.php >> ../project/patches/Y_m_d_His_repo_something.patch

cd ../project
vi patches/Y_m_d_His_repo_something.patch
# 修改patch里面的文件路径，否则会报错，参考格式：https://gist.github.com/sinkcup/39c8ce69e78d12287789606208e3901c
patch -p0 < patches/Y_m_d_His_repo_something.patch
./phpunit.sh
```

### 贡献到开源项目

```
# create issue on github.com/org/package, get issue ID xxx
cd ../package
git checkout -b issue-xxx
git add
git commit -m 'new/fix: a feature/a bug. close org/package#xxx'
git push origin issue-xxx
# New pull request
```
