# Birthday Calendar Add-on for Thunderbird

.PHONY: xpi xpi-unsupported clean clobber

xpi: dist/birthdaycalendar.xpi
xpi-unsupported: dist/birthdaycalendar-unsupported.xpi

clean:
	rm -Rf build

clobber: clean
	rm -Rf dist

SRCFILES := $(shell find src -type f \
	-not -path 'src/manifest.json' \
	-not -name '.*' \
	)

build/version.txt: .git/index $(SRCFILES) LICENSE
	mkdir -p "$(@D)"
	git describe --match='v[0-9]*' --dirty=+ | sed -e 's/^v//g' > "$@"

build/manifest.json: src/manifest.json build/version.txt
	sed -e "s/__BUILD_version__/$(shell cat build/version.txt)/g" "$<" > "$@"

dist/birthdaycalendar.xpi: $(SRCFILES) build/manifest.json LICENSE
	mkdir -p "$(@D)"
	rm -f "$@"
	cd src ; zip -9X "../$@" $(SRCFILES:src/%=%)
	cd build ; zip -9X "../$@" manifest.json
	zip -9X "$@" LICENSE

build/unsupported/manifest.json: src/manifest.json build/version.txt
	mkdir -p "$(@D)"
	sed -e "s/__BUILD_version__/$(shell cat build/version.txt)-unsupported/g" \
	    -e 's/"strict_max_version": "[^"]*"/"strict_max_version": "*"/g' \
	    "$<" > "$@"

dist/birthdaycalendar-unsupported.xpi: $(SRCFILES) build/unsupported/manifest.json LICENSE
	mkdir -p "$(@D)"
	rm -f "$@"
	cd src ; zip -9X "../$@" $(SRCFILES:src/%=%)
	cd build/unsupported ; zip -9X "../../$@" manifest.json
	zip -9X "$@" LICENSE
