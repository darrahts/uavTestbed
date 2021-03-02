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
  <p align="center"><a href="https://ti.arc.nasa.gov/tech/asr/groups/planning-and-scheduling/">Planning and Scheduling Group</a></p>

  <h1 align="center">UAV Simulation Testbed</h3>

  <p align="center">
    A testbed for the development of prognostic, health management, and decision making algorithms using MATLAB and Simulink.
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

Work in progress!

TODO
- ~~update [truesystem.slx](https://github.com/darrahts/uavTestbed2/blob/main/truesystem.slx)~~
    - ~~output to workspace variables organized~~
    - ~~condition monitors redone~~
    - ~~ukf covariance outputs~~
- ~~fix degradation parameter standard deviation~~
    - ~~start large, update based on ukf~~
    - ~~dont forget the motor filter!~~
- ~~integrate parallelization
    - ~~WORK IN PROGRESS~~
    - ~~see below `scratch paper` section of [next_paper.mlx](https://github.com/darrahts/uavTestbed2/blob/main/next_paper.mlx)~~
- ~~rewrite RUL experiment from last paper using new framework~~
    - ~~parallel execution of digitaltwin~~
    - ~~rul distribution~~
    - ~~execute real system~~
    - ~~update degradation parameters~~
    - ~~repeat until digitaltwin fails~~
- create training data set
- build NN model to decide on mission or maintenance
- add power demand estimation based on trajectory (ask Chris about this)
- add in-mission decision making and actions
    - activities such as drop package, take picture, transmit data, etc
    - appropriate power demand based on activity
- more...



### Prerequisites

* MATLAB >= R2020a
    - Parallel Computing Toolbox
    - Simulink
    - Robotics System Toolbox

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/darrahts/uavTestbed2.git
   ```

<!-- USAGE EXAMPLES -->
## Usage

Open the livescript `next_paper.mlx`  
Run the cells until "scratch paper below" cell  


Discuss the following:  
- parallelized PF-based RUL estimation
- trajectory generation
- RUL estimation
- Degradation
- parameter approximation
- parameter value estimation
- train/test/validation data

<!-- ROADMAP -->
## Roadmap

To be incorporated:  

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
## Contributing
Project contributors (direct or indirect):  
- Marcos Quinones  
- Gautam Biswas  
- Chetan Kulkarni  
- Chris Teubert  
- Jeremy Frank  
- Ibrahim Ahmed  
  

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

Project Link: [https://github.com/darrahts/uavTestbed2](https://github.com/darrahts/uavTestbed2)

<!-- PUBLICATIONS -->
## Publications
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
