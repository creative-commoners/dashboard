# Creative Commoners dashboard

This dashboard shows metrics for the Creative Commoners and Open Sourcerers.

## Installation

* Clone this repository
* Install the app with one of the methods described below (host or docker install)
* Go to `http://localhost:3030`

### Host install:
* Ensure you have [Smashing](https://github.com/Smashing/smashing) requirements set up
* Define API tokens in your environment (e.g. `export TRAVIS_ACCESS_TOKEN=....`)
* Run `smashing start`

### Docker install:
* copy `.env.dist` to `.env` and fill in the gaps with your API tokens
* Run `./docker/run.sh` or `cd docker && docker-compose up`

## Configuration

Place configuration in the `config.yml` file. See `config.yml.template` for an example of configuration options.

### API tokens

Put API tokens in environment variables:

* `TRAVIS_ACCESS_TOKEN` (note: this should be from travis-ci.org, not from .com)

## Based on github-dashing

This [Smashing](https://github.com/Smashing/smashing) dashboard is sort of a fork of @chillu's
[github-dashing](https://github.com/chillu/github-dashing/) dashboard, which is based on Dashing.
