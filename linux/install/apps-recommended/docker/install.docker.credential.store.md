# Docker Credential Store Installation

To use `pass` as the Docker credential store, first install it:

```bash
sudo apt-get install pass
```

> **Note:** You need to specify the credentials store in `$HOME/.docker/config.json` to tell the Docker engine to use it. The value of the config property should be the suffix of the program to use (i.e., everything after `docker-credential-`).

If you are currently logged in, run `docker logout` to remove the credentials from the file and run `docker login` again.

Now, put the following configuration into your config file (`$HOME/.docker/config.json`):

```json
{
  "credsStore": "pass"
}
```
