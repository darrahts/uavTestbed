[![Contributors][contributors-shield]][contributors-url]
[![LinkedIn][linkedin-shield]][linkedin-url]
<!--
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
-->



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://lab.vanderbilt.edu/vumacs/">
    <img src="https://whitelabel.2u.com/cdn/v1/vu-eng/logo-1.png" alt="Logo" width=300>
  </a>
  <br />
  <a href="https://ti.arc.nasa.gov/">
    <img src="https://ti.arc.nasa.gov/m/site/img/nasa_header_logo1.gif">
  </a>
  
  <p align="center"><a href="https://ti.arc.nasa.gov/tech/dash/groups/pcoe/">Prognostics Center of Excellence</a></p>
  <p align="center"><a href="https://ti.arc.nasa.gov/tech/dash/groups/diagnostics-and-prognostics/">Diagnostics and Prognostics Group</a></p>
  <p align="center"><a href="https://ti.arc.nasa.gov/tech/asr/groups/planning-and-scheduling/">Planning and Scheduling Group</a></p>

  <h1 align="center">UAV Simulation Testbed</h3>

  <p align="center">
    A testbed for the development of prognostic, health management, and decision making algorithms. 
    <br />
    <a href="https://github.com/darrahts/uavTestbed2"><strong>Explore the docs »</strong></a>
    <br />
    <a href="https://github.com/darrahts/uavTestbed2">View Demo</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#prerequisites">Prerequisites</a></li>
    <li><a href="#installation">Installation</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#publications">Publications</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
This is a complete UAV simulation testbed that is intended to be used with the [data management framework](https://github.com/darrahts/data_management_framework). A Postgres database schema and an API in MATLAB / python is used in conjunction. This framework will support a wide variety of simulation-based experiments as well as real-world experiments using the same interface.  

This is a Work In Progress [WIP]! Updates are being made as of July 15th, 2022. Many of these steps may remain out of date for the time being.

Currenlty we are conducting several run-to-failure experiments in effort to collect telementry and degradation data to facilitate research into deep learning approaches to problems such as remaining useful life (RUL) estimation, fault detection & isolation (FDI), decision making, and others.  

TODO
- finish refactoring the framework
- add power demand estimation based on trajectory
- add in trajectory risk / reward 
- add in-mission decision making and actions
    - activities such as drop package, take picture, transmit data, etc
    - appropriate power demand based on activity
- more...



### Prerequisites

* PostgreSQL 12+ (other versions are probably fine but untested)
* MATLAB r2022a (r2020 had database issues and now some functionality has been updated in r2022a that is not backwards compatible with r2020).

### Setup

1. Clone this repo `git clone https://github.com/darrahts/uavTestbed && cd uavTestbed`

2. Clone the [data management framework repo](https://github.com/darrahts/data_management_framework) and follow the installation instructions to install postgres and timescaledb. NOTE: windows ports of some scripts are in progress. 

3. Execute the SQL scripts which extend the data management framework for the UAV simulation.

4. **Optional** Install [DBeaver](https://dbeaver.io/download/), a database management application and follow [the guide here](https://github.com/darrahts/uavTestbed/blob/main/postgres_dbeaver_guide.pdf) to set up a remote connection to your database.  

5. **Optional** Install [VS Code](https://code.visualstudio.com/docs/remote/ssh).


## Usage

**Note**
  - There is an [active support case](https://www.mathworks.com/matlabcentral/answers/685033-sqlwrite-broken-in-r2020b-vs-r2020a-for-date-time-types) regarding an error with code in MATLAB's database toolbox that drops miliseconds from the telemetry data. This causes the transaction to fail due to violating the unique constraint on the dt column. The current workaround is to sample the at 1hz. 

**NOTE** This has been tested on Windows 10 with ODBC driver and R2020a. Currently working on a Linux implementation with the native postgres driver and R2021a. Here is [another active support case](https://www.mathworks.com/matlabcentral/answers/1441564-sqlwrite-still-broken-in-r2021a-for-datatype-conversions?s_tid=srchtitle) regarding the errors within MATLAB.

Run the file [example.mlx](https://github.com/darrahts/uavTestbed/blob/main/livescripts/example.mlx). The original octocopter and dynamics are no longer supported (although still work), and therefore it is recommended to use the tarot uav instead (it is also alot faster due to different implementation of the dynamics). 

**Prerequisites**
  - setup a database following the above instructions and included the default setups
  - have the database connection setup in MATLAB ([instructions here](https://www.mathworks.com/help/database/ug/configuring-driver-and-data-source.html))



Discuss the following: 
- database schema (PHM 2021 paper)
- trajectory selection (aerospace journal paper)
- Degradation (2020 AIAA paper)
- RUL estimation
- parameter estimation 
- train/test/validation data

<!-- ROADMAP -->
## Roadmap

To be incorporated:  

* takeoff and landing 
* prognostics-based waypoint selection
* power estimation based on trajectory
* 4D flight plan
* dynamic craft speed based on flight plan
* mission or maintenance scheduling
* optimize flight time vs maintenance time
* in-mission decision making
* NN-based decision making
* multi-agent mission assignment
* multi-agent resource allocation 
* more...

<!-- CONTRIBUTING -->
## Mentors  
- Gautam Biswas   
- Marcos Quinones
- Jeremy Frank 
- Chetan Kulkarni  
- Chris Teubert  


## Technical contributors
  

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Tim Darrah - timothy.s.darrah@vanderbilt.edu

Project Link: [https://github.com/darrahts/uavTestbed](https://github.com/darrahts/uavTestbed)

<!-- PUBLICATIONS -->
## Publications
* To Appear: **A Data Management Framework & UAV Simulation Testbed for the Study of Prognostics Technologies**, [PHM 2021. Nashville, TN.](https://phm2021.phmsociety.org/)
* [Prognostics Based Decision Making for Safe and Optimal UAV Operations (2021)](https://arc.aiaa.org/doi/abs/10.2514/6.2021-0394)
* [The Effects of Component Degradation on System-Level Prognostics for the Electric Powertrain System of UAVs (2020)](https://arc.aiaa.org/doi/abs/10.2514/6.2020-1626)
* [A Decision-Making Framework for Safe Operations of Unmanned Aerial Vehicles in Urban Scenarios (2020)](https://phmpapers.org/index.php/phmconf/article/view/1190)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [NASA OSTEM Fellowship 20-0154](https://www.nasa.gov/stem/fellowships-scholarships/index.html)
* [NASA Shared Services Center Grant 80NSSC19M0166](https://www.nasa.gov/centers/nssc)

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/darrahts/uavtestbed2.svg?style=for-the-badge
[contributors-url]: https://github.com/darrahts/uavTestbed2/graphs/contributors

[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/timothydarrah/
[product-screenshot]: images/screenshot.png
