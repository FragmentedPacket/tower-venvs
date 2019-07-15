VENV_BASE := /opt/custom-venvs
PY2_VENVS := $(subst py2/,,$(wildcard py2/*))
PY3_VENVS := $(subst py3/,,$(wildcard py3/*))
USERNAME ?= admin
PASSWORD ?= password
SERVER ?= 192.168.200.113

create_venvs:
	make install create_venv_base_dir; \
	for venv in $(PY2_VENVS); do \
		make install_py2_envs_$$venv; \
	done; \
	for venv in $(PY3_VENVS); do \
		make install_py3_envs_$$venv; \
	done;
	make add_custom_venvs_to_tower

create_venv_base_dir:
	if [ ! -d "$(VENV_BASE)" ]; then \
		mkdir $(VENV_BASE); \
		chmod 0755 $(VENV_BASE); \
	fi; \

add_custom_venvs_to_tower:
	curl -u $(USERNAME):$(PASSWORD) -X PATCH 'https://$(SERVER)/api/v2/settings/system/' \
	-d '{"CUSTOM_VENV_PATHS": ["$(VENV_BASE)"]}' \
	-H 'Content-Type: application/json' \
	-k \

install_py2_envs_%:
	if [ "$(VENV_BASE)" ]; then \
		if [ ! -d "$(VENV_BASE)/$*" ]; then \
			virtualenv $(VENV_BASE)/$*; \
			source $(VENV_BASE)/$*/bin/activate; \
			umask 0022; \
			pip install -U pip; \
			pip install -r py2/$*/requirements.txt; \
		else \
			$(VENV_BASE)/$*/bin/pip install -U pip; \
			$(VENV_BASE)/$*/bin/pip install -U -r py2/$*/requirements.txt; \
		fi; \
	fi

install_py3_envs_%:
	yum install -y python36-devel python-devel gcc; \
	if [ "$(VENV_BASE)" ]; then \
		if [ ! -d "$(VENV_BASE)/$*" ]; then \
			python3 -m venv --system-site-packages $(VENV_BASE)/$*; \
			source $(VENV_BASE)/$*/bin/activate; \
			umask 0022; \
			pip install -r py3/$*/requirements.txt; \
		else \
			$(VENV_BASE)/$*/bin/pip install -U pip; \
			$(VENV_BASE)/$*/bin/pip install -U -r py3/$*/requirements.txt; \
		fi; \
	fi
