# Print Lab

## Overview
You can find the live application at [print-lab.tech](https://print-lab.tech/). This service provides 3D printing services.

## Technologies Used
| Technology                | Details          |
|---------------------------|------------------|
| **Ruby on Rails**         | Rails Version: 7.2.1.2<br>Ruby Version: 3.3.5 |
| **CSS Preprocessor**      | Sass             |
| **JavaScript Bundler**    | Vite             |
| **JavaScript Package Manager** | Yarn        |
| **Database**              | PostgreSQL (RDS) |
| **Hosting**               | AWS EC2          |


## Installation
1. Clone the repository:
    ```sh
    git clone <repository-url>
    cd <repository-directory>
    ```

2. Install dependencies:
    ```sh
    gem install bundler --conservative
    bundle install
    yarn install
    ```

3. Set up the database:
    ```sh
    bin/rails db:prepare
    ```

## Running the Application
To start the application, run:
```sh
bin/rails server
```
