all:
	cd +braidlab/private; make all
	cd +braidlab/@braid/private; make all
	cd +braidlab/@cfbraid/private; make all

clean:
	cd +braidlab/private; make clean
	cd +braidlab/@braid/private; make clean
	cd +braidlab/@cfbraid/private; make clean