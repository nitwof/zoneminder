GOMPLATE = gomplate
TEMPLATES_DIR = ./templates
PARTIALS_DIR = $(TEMPLATES_DIR)/partials
DIST_DIR = ./dist
PLATFORMS_DIR = ./platforms

PLATFORMS_FILES = $(wildcard $(PLATFORMS_DIR)/*.yaml)
PLATFORMS = $(PLATFORMS_FILES:$(PLATFORMS_DIR)/%.yaml=%)

TEMPLATES = $(wildcard $(TEMPLATES_DIR)/*.tmpl)

PARTIALS=$(shell find $(PARTIALS_DIR) -type f -name "*.tmpl")
PARTIALS_MAP=$(join $(PARTIALS:$(PARTIALS_DIR)/%.tmpl=%=), $(PARTIALS))

OUTPUTS = $(TEMPLATES:$(TEMPLATES_DIR)/%.tmpl=%)

default: generate

%: $(PLATFORMS_DIR)/%.yaml .FORCE
	@mkdir -p $(DIST_DIR)/$@
	gomplate \
		$(addprefix -f , $(TEMPLATES)) \
		$(addprefix -t , $(PARTIALS_MAP)) \
		$(addprefix -o $(DIST_DIR)/$@/, $(OUTPUTS)) \
		-d platform=$<

generate: $(PLATFORMS)

build-zm:
	docker build \
		-t zoneminder:1.34-cuda9.1-cudnn7 \
		--build-arg zm_version=1.34 \
		-f $(DIST_DIR)/cuda9.1-cudnn7/Dockerfile \
		./context

build-zm-es:
	docker build \
	-t zoneminder:1.34-es6.0.6-cuda9.1-cudnn7 \
	--build-arg zm_version=1.34 \
	--build-arg zmeventnotification_version=6.0.6 \
	-f $(DIST_DIR)/cuda9.1-cudnn7/es.Dockerfile \
	./context

.PHONY: default generate build-zm build-zm-es
.FORCE: