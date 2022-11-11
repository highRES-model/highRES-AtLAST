[![DOI](https://zenodo.org/badge/564717619.svg)](https://zenodo.org/badge/latestdoi/564717619)

# highRES-AtLAST

This repository contains the AtLAST version of highRES.

### **What is highRES**?

It is a high temporal and spatial resolution electricity system model used to plan least-cost electricity systems. This model is specifically designed to analyse the effects of high shares of variable renewables and explore integration/flexibility options, comparing and trading off potential options to integrate renewables into the system. This model is capable of including the extension of the transmission grid, interconnection with other countries, building flexible generation (e.g. gas power stations), renewable curtailment and energy storage.

highRES is written in GAMS and its objective is to minimise power system investment and operational costs to meet hourly demand, subject to a number of system constraints. The transmission grid is represented using a linear transport model. To realistically model variable renewable supply, the model uses spatially and temporally-detailed renewable generation time series that are based on weather data.

### **How to run the model**

This repository contains all GAMS code (.gms files) and necessary input data (.dd files) for a 8760 hour model run. 
To execute the code follow these steps:

1. GAMS must be installed and licensed. This version was tested and developed with GAMS version 36.1.0.
2. GAMS files (.gms) must be in the same directory and input files (.dd) must be in the folder "data_inputs".
3. Open highres.gms (the main driving script for the model) in GAMS IDE or GAMS Studio, and then hit run.
4. Full model outputs are written into the file "AtLAST_2030.gdx" (or hR_dev_<scenario_name>.gdx, according to the scenario executed in GAMS) which is written into the same directory as the code and can be viewed using the GAMS IDE/GAMS Studio. Outputs include: the capacity of generation, storage and transmission by node, the hourly operation of these assets (including flows into and out of storage plus the storage level and total system costs)
5. The GDX output file can be converted to SQLite using the command line utility gdx2sqlite which is distributed with GAMS. From the command line do "gdx2sqlite -i hR_dev.gdx -o hR_dev.db -fast". This SQLite database can then be easily read by Python using, e.g., Pandas.
6. For other options and decide which scenario is executed, you can read the specific instructions in highres.gms.

### **Data**

This model uses the following data sources:
- ERA5 for weather data (https://www.ecmwf.int/en/forecasts/datasets/reanalysis-datasets/era5) 
- Atlite software to convert weather data into PV and CSP capacity factors (https://github.com/PyPSA/atlite)
- Demand data is obtained from estimation of the telescope load
- Cost and technical data are obtained from different sources. More detail see the corresponding publication.
