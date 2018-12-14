# Jenkins Pull-Request Tester Docker Image

Lets you test a pull-request on the Jenkins project in a clean environment.

## How to use

* Have a look at the [pull requests on the Jenkins project](https://github.com/jenkinsci/jenkins/pulls)
* Select one, and copy its number (see on the URL)
* Pass that number to the Docker container:

```shell
$ docker run --rm -ti -p 8080:8080 -e ID=2200 batmat/jenkins-pr-tester
```

* Open your browser on http://localhost:8080 and test

## Misc
### WTF: that image is very big, and one layer is 500+ MB!

To accelerate testing at __run__time, the Docker image has been _built_ trying to cache
as much as possible things required to build Jenkins.
Like, for example, the Jenkins Maven dependencies both for 1.x and 2.x.
That results in a *very* big layer especially for that part.

The goal is that Maven has ideally to download no new dependency to build the requested
pull request.
