all:
	dcc32 -$M+ MarubatsuTest.dpr

clean:
	del MarubatsuTest.exe
	del MarubatsuTest.xml

test: clean all
	MarubatsuTest.exe
