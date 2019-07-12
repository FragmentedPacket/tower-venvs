VENV_BASE = /var/lib/awx/venv
PY2_VENVS = $(subst py2/,,$(wildcard py2/*))
PY3_VENVS = $(subst py3/,,$(wildcard py3/*))

create_venvs:
	for venv in $(PY2_VENVS); do \
		make install_py2_envs_$$venv; \
	done;
	for venv in $(PY3_VENVS); do \
		make install_py3_envs_$$venv; \
	done;

install_py2_envs_%:
	if [ "$(VENV_BASE)" ]; then \
		if [ ! -d "$(VENV_BASE)/$*" ]; then \
			virtualenv $(VENV_BASE)/$*; \
			$(VENV_BASE)/$*/bin/pip install -U pip; \
			$(VENV_BASE)/$*/bin/pip install -r py2/$*/requirements.txt; \
		fi; \
	fi

install_py3_envs_%:
	if [ "$(VENV_BASE)" ]; then \
		yum install -y python36-devel python-devel gcc; \
		if [ ! -d "$(VENV_BASE)/$*" ]; then \
			python3 -m venv --system-site-packages $(VENV_BASE)/$*; \
			$(VENV_BASE)/$*/bin/pip install -U pip; \
			$(VENV_BASE)/$*/bin/pip install -r py3/$*/requirements.txt; \
		fi; \
	fi
