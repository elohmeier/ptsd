all: .drone.yml

# https://discourse.drone.io/t/porting-matrix-builds-to-1-0-multi-machine-pipelines/2966
.drone.yml: .drone.jsonnet
	drone jsonnet --stream
