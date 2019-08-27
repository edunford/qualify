# qualify

In the social sciences, researchers regularly engage in manual data coding tasks to produce novel data relevant to their specific research topics. However, manual data collection is a messy process that often lacks transparency regarding how these data are generated. We propose an `R` package, `qualify`, that allows researchers to easily construct a browser-based application for any manual coding data task. The application, once deployed, can sync seamlessly with cloud-based data resources (such as Azure or AWS) to allow for the construction of a reliable database where all coded information is consistently saved, metadata regarding how variables are coded is retained, and real-time tracking of data quality is reported. The package offers a user-friendly implementation of a sophisticated infrastructure that allows for the easy implementation of best practices in data generation and transparency. Moreover, the application eases the distribution of coding tasks to research assistants.

## Development

The project is currently in **_beta_**, but we aim to have a working beta version of the package up (functional on Mac OS) by the end of summer 2019.

## Usage

**Important commands**

`make build` installs js dependencies from npm

`make run` starts up the R and React servers
