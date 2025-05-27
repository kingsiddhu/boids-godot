# Boids-Godot 3D
## Getting Started

### Prerequisites
You need [Godot](https://godotengine.org/download).
Although this was made in 4.4, you can copy the nessessary files to older versions.\
Note: The code may break when opened in an older version

### Installing
 1. Clone or download this repository and open the project in godot

 2. Copy the following files in assets to your project (Wherever suitable) to use the boid simulation in your project.

    ```
    Avoider.tscn
    avoidermarker.gd
    boidResource.gd
    boidSpawner.gd
    boidSpawner.tscn
    boid.gd
    ```
 3. Add `boidSpawner.tscn` to your scene and toggle Editable Children.

 4. Create your own boid Resource with the nessessary data and set boid count.

 5. To the boid Resource you need to attach a boid scene for that make a scene with Node3D base and attach a mesh and boid.gd to the Node3D base.
 
    *its really simple and you can modify it easily. Just dont change the already set variables.
 6. Add Avoider.tscn to `boidSpawner/Avoiders` and set mul (size of it basically)
 7. For boids to avoid free roaming bodies make sure the collision layer & mask is set properly and the body needs to have a `mul` var assigned and needs to be in a group called `Avoider_boid`'
 <br><br><br>

## Authors

 - [Siddharth Katabathula](https://kingsiddhu.github.io) - **Main Author** (*Only one*)

## Built With
 - [Godot v4.4.1.stable.official](https://godotengine.org/)

## License
The project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.