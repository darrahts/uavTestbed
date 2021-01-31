
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
<!--
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
-->
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://lab.vanderbilt.edu/vumacs/">
    <img src="https://whitelabel.2u.com/cdn/v1/vu-eng/logo-1.png" alt="Logo" width=300>
  </a>

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

<!-- 
[![Screenshot][product-screenshot]](https://example.com)
-->
about here

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

<!-- ROADMAP -->
## Roadmap

To be incorporated:  

* mission or maintenance scheduling
* optimize flight time vs maintenance time
* in-mission decision making
* NN-based decision making
* multi-agent mission assignment
* multi-agent resource allocation 
* more...

<!-- CONTRIBUTING -->
## Contributing

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
