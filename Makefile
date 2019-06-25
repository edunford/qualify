build: 
	cd user_interface; \
	npm install

run:
	cd user_interface; \
	Rscript api/run_api.R& npm start