GOMPLATE = gomplate
CONTEXTS_DIR = ./contexts
DIST_DIR = ./dist
TEMPLATES_DIR = ./templates

CONTEXTS = $(wildcard $(CONTEXTS_DIR)/*.yaml)
DISTS = $(CONTEXTS:$(CONTEXTS_DIR)/%.yaml=$(DIST_DIR)/%)

default: generate

$(DIST_DIR)/%: $(CONTEXTS_DIR)/%.yaml .FORCE
	@mkdir -p $@
	gomplate \
		--input-dir $(TEMPLATES_DIR) \
		--output-dir $@ \
		-c .=$<

generate: $(DISTS)

.PHONY: default generate
.FORCE: