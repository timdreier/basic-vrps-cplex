# Implementation of some basic vehicle routing problems (VRP) in IBM ILOG CPLEX
This is a set of some basic [vehicle routing problems (VRP)](https://en.wikipedia.org/wiki/Vehicle_routing_problem). The following models from the literatur has been used:

* **ACVRP**: _Models, relaxations and exact approaches for the capacitated vehicle routing problem_ (Paolo Toth, Daniele Vigo)
* **SCVRP**: _A survey of recent advances in vehicle routing problems_ (Aderemi Oluyinka Adewumi, Olawale Joshua Adeleke)
* **MDVRP**: _A literature review on the vehicle routing problem with multiple depots_ (Jairo R. Montoya-Torres, Julián López Franco, Santiago Nieto Isaza, Heriberto Felizzola Jiménez, Nilson Herazo-Padilla)

The implementation comes with some sample data I used in my bachelor thesis. It can be replaced with any data in the CSV-format like:

`name;latitude;longditude;demand`

In ACVRP and SCVRP the depot is represented by the first entry in the csv-file. In MDVRP the depots and customers are stored in seperate files. The number of customers (and depots) can be adjusted in the settings.dat in each model.

## Visualization of results
There is a seperate tool to visualize the output the models generate. This is availabe under [https://timdreier.github.io/csv-routes-display/](https://timdreier.github.io/csv-routes-display/). The sourcode is available under [https://github.com/timdreier/csv_route_display](https://github.com/timdreier/csv_route_display).