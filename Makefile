# Proxy Configuration
ifneq (x${NO_PROXY}${FTP_PROXY}${HTTP_PROXY}${HTTPS_PROXY},x)
PROXY = env
endif

ifneq (x${NO_PROXY},x)
PROXY += NO_PROXY=${NO_PROXY}
endif

ifneq (x${FTP_PROXY},x)
PROXY += FTP_PROXY=${FTP_PROXY}
endif

ifneq (x${HTTP_PROXY},x)
PROXY += HTTP_PROXY=${HTTP_PROXY}
endif

ifneq (x${HTTPS_PROXY},x)
PROXY += HTTPS_PROXY=${HTTPS_PROXY}
endif

.PHONY: up
up:
	@docker-compose up -d
# Boot Wait...
	@while true; do echo Waiting... && curl -s -o /dev/null http://localhost:8088 && break || sleep 3; done
# Default Settings
	@docker exec redmine env RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data
# Memcached Install
	@docker exec redmine sh -c "echo 'config.cache_store = :mem_cache_store, \"memcached\"' > config/additional_environment.rb"
	@docker exec redmine sh -c "echo \"gem 'dalli'\" > Gemfile.local"
	@docker exec redmine $(PROXY) bundle install
	@docker exec redmine passenger-config restart-app /usr/src/redmine
# Redmine Configuration
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('search_results_per_page','30');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('text_formatting','markdown');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_language','ja');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('force_default_language_for_anonymous','1');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('force_default_language_for_loggedin','1');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('user_format','lastname_firstname');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('thumbnails_enabled','1');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('login_required','1');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('autologin','30');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('max_additional_emails','0');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('session_lifetime','43200');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('session_timeout','480');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_users_time_zone','Tokyo');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('rest_api_enabled','1');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('jsonp_enabled','1');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_projects_public','0');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_projects_modules','---\n- issue_tracking\n- time_tracking\n- wiki\n- repository\n- calendar\n- gantt\n');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_projects_tracker_ids','---\n- \'1\'\n- \'2\'\n- \'3\'\n');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('cross_project_issue_relations','1');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_issue_start_date_to_creation_date','0');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('issue_done_ratio','issue_status');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('issue_list_default_totals','---\n- estimated_hours\n- spent_hours\n');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('attachment_max_size','51200');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('repositories_encodings','utf-8,cp932,euc-jp');"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('enabled_scm','---\n- Git\n');"
	@docker exec redmine passenger-config restart-app /usr/src/redmine

.PHONY: down
down:
	@docker-compose down

.PHONY: clean
clean: down
	@sudo rm -fr ./files
	@sudo rm -fr ./log
	@sudo rm -fr ./mysql
	@sudo rm -fr ./plugins
	@sudo rm -fr ./themes
