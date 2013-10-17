#!/bin/bash
# Bootstrap an R/travis environment.

set -e

Bootstrap() {
  # Install the dependencies.
  sudo apt-get update -qq
  sudo apt-get install python-software-properties texlive-full texlive-fonts-extra

  # Set up our CRAN mirror.
  sudo add-apt-repository "deb http://cran.rstudio.com/bin/linux/ubuntu precise/"
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
  sudo apt-get update -qq

  # Install R.
  sudo apt-get install r-base r-base-dev

  # Install devtools.
  R --slave --vanilla -e 'install.packages(c("devtools"), repos=c("http://cran.rstudio.com"))'
}

GithubPackage() {
  # An embarrassingly awful script for calling install_github from a
  # .travis.yml.
  #
  # Note that bash quoting makes this annoying for any additional
  # arguments.

  # Get the package name and strip it
  PACKAGE_NAME=$1
  shift

  # Join the remaining args.
  ARGS=$(echo $* | sed -e 's/ /, /g')
  if [ -n "${ARGS}" ]; then
    ARGS=", ${ARGS}"
  fi

  # Install the package.
  R --slave --vanilla -e "library(devtools); install_github(\"${PACKAGE_NAME}\"${ARGS})"
}

InstallDeps() {
  R --slave --vanilla -e 'library(devtools); imports <- parse_deps(as.package(".")$imports)$name; if (length(imports) > 0) install.packages(imports, repos=c("http://cran.rstudio.com"))'
  R --slave --vanilla -e 'library(devtools); suggests <- parse_deps(as.package(".")$suggests)$name; if (length(suggests) > 0) install.packages(suggests, repos=c("http://cran.rstudio.com"))'
}

COMMAND=$1
shift
case $COMMAND in
  "bootstrap")
    Bootstrap
    ;;
  "github_package")
    GithubPackage
    ;;
  "install_deps")
    InstallDeps
    ;;
esac