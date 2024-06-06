# WordPress Project Scaffold

This tool provides a streamlined and opinionated approach to kickstart a local
development environment for your WordPress project. It's designed to save you
time and effort, allowing you to focus on building your WordPress site right
away.

## Prerequisites

Before you begin, ensure you have the following prerequisites installed and
configured on your system:

- [Docker Engine](https://docs.docker.com/engine/install/): For container
  management. We recommend using [OrbStack](https://orbstack.dev/) for a faster
  and more efficient alternative.
- [mkcert](https://github.com/FiloSottile/mkcert): For creating locally trusted
  SSL certificates.

Also ensure that your `/etc/hosts` file includes the entry `127.0.0.1
your-project.test`. Alternatively, you can automate this process using a tool
like [Dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html).

## Installation

To install the WordPress Project Scaffold, follow these steps:

1. Add the custom Homebrew tap:

    ```shell
      brew tap somoscuatro/homebrew-wp-project-scaffold
    ```

2. Install the wp-project-scaffold tool via Homebrew:

    ```shell
      brew install wp-project-scaffold`
    ```

## Usage

To initiate your WordPress project, simply execute the following command:

```shell
wp-project-scaffold
```

Running this command will:

Set up a local WordPress development environment using the [somoscuatro Docker
Compose configuration](https://github.com/somoscuatro/docker-wordpress-local).
Optionally, install the [somoscuatro WordPress Starter
Theme](https://github.com/somoscuatro/sc-starter-theme) to jumpstart your theme
development. For more detailed information and advanced usage, please refer to
the respective GitHub repositories linked above.

Happy coding, and enjoy building your WordPress site with ease!

## How to Contribute

Any kind of contribution is very welcome!

Please, be sure to read our [Code of
Conduct](https://raw.githubusercontent.com/somoscuatro/homebrew-wp-project-scaffold/main/CODE_OF_CONDUCT.md).

If you notice something wrong please open an issue or create a Pull Request or
just send an email to [tech@somoscuatro.es](mailto:tech@somoscuatro.es). If you
want to warn us about an important security vulnerability, please read our
Security Policy.

## License

All code is released under MIT license version. For more information, please
refer to
[LICENSE.md]((https://raw.githubusercontent.com/somoscuatro/homebrew-wp-project-scaffold/main/LICENSE.md))
file.
