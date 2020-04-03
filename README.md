# Adjusted GitHub Viewer

Searches GitHub repositories.

## Installation

You have to register a [new github application](https://github.com/settings/applications/new) and set up its credentials
as described below.

### The Docker Way

Prerequisites: docker-compose v. 1.13.0 or newer.


In `.env` file, replace the values of `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` with the respective values that you
received after registering a github application.

Run app:

```
docker-compose up app
```

Run tests:

```
docker-compose up tests
```

### The Native Way

Prerequisites: ruby v. 2.7.1.

Export the necessary variables in your shell (or in your shell RC file, e.g. `.zshrc`/`.bashrc`), replacing `<VALUE>` with the real values:

```
export GITHUB_CLIENT_ID=<VALUE>
export GITHUB_CLIENT_SECRET=<VALUE>
```

Run app:

```
./bin/start
```

Run tests:

```
./bin/tests
```

## Usage

One the app starts, visit http://localhost:3000/ in your browser.
