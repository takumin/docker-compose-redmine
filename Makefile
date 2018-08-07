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
	@docker exec redmine bundle install
	@docker exec redmine passenger-config restart-app /usr/src/redmine
# Redmine Configuration
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('search_results_per_page','30') ON DUPLICATE KEY UPDATE name='search_results_per_page', value='30';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('text_formatting','markdown') ON DUPLICATE KEY UPDATE name='text_formatting', value='markdown';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_language','ja') ON DUPLICATE KEY UPDATE name='default_language', value='ja';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('force_default_language_for_anonymous','1') ON DUPLICATE KEY UPDATE name='force_default_language_for_anonymous', value='1';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('force_default_language_for_loggedin','1') ON DUPLICATE KEY UPDATE name='force_default_language_for_loggedin', value='1';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('user_format','lastname_firstname') ON DUPLICATE KEY UPDATE name='user_format', value='lastname_firstname';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('thumbnails_enabled','1') ON DUPLICATE KEY UPDATE name='thumbnails_enabled', value='1';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('login_required','1') ON DUPLICATE KEY UPDATE name='login_required', value='1';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('autologin','30') ON DUPLICATE KEY UPDATE name='autologin', value='30';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('max_additional_emails','0') ON DUPLICATE KEY UPDATE name='max_additional_emails', value='0';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('session_lifetime','43200') ON DUPLICATE KEY UPDATE name='session_lifetime', value='43200';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('session_timeout','480') ON DUPLICATE KEY UPDATE name='session_timeout', value='480';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_users_time_zone','Tokyo') ON DUPLICATE KEY UPDATE name='default_users_time_zone', value='Tokyo';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('rest_api_enabled','1') ON DUPLICATE KEY UPDATE name='rest_api_enabled', value='1';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('jsonp_enabled','1') ON DUPLICATE KEY UPDATE name='jsonp_enabled', value='1';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_projects_public','0') ON DUPLICATE KEY UPDATE name='default_projects_public', value='0';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_projects_modules','---\n- issue_tracking\n- time_tracking\n- wiki\n- repository\n- calendar\n- gantt\n') ON DUPLICATE KEY UPDATE name='default_projects_modules', value='---\n- issue_tracking\n- time_tracking\n- wiki\n- repository\n- calendar\n- gantt\n';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_projects_tracker_ids','---\n- \'1\'\n- \'2\'\n- \'3\'\n') ON DUPLICATE KEY UPDATE name='default_projects_tracker_ids', value='---\n- \'1\'\n- \'2\'\n- \'3\'\n';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('cross_project_issue_relations','1') ON DUPLICATE KEY UPDATE name='cross_project_issue_relations', value='1';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('default_issue_start_date_to_creation_date','0') ON DUPLICATE KEY UPDATE name='default_issue_start_date_to_creation_date', value='0';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('issue_done_ratio','issue_status') ON DUPLICATE KEY UPDATE name='issue_done_ratio', value='issue_status';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('issue_list_default_totals','---\n- estimated_hours\n- spent_hours\n') ON DUPLICATE KEY UPDATE name='issue_list_default_totals', value='---\n- estimated_hours\n- spent_hours\n';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('attachment_max_size','51200') ON DUPLICATE KEY UPDATE name='attachment_max_size', value='51200';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('repositories_encodings','utf-8,cp932,euc-jp') ON DUPLICATE KEY UPDATE name='repositories_encodings', value='utf-8,cp932,euc-jp';"
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e "INSERT INTO settings (name, value) VALUES ('enabled_scm','---\n- Git\n') ON DUPLICATE KEY UPDATE name='enabled_scm', value='---\n- Git\n';"
	@docker exec redmine passenger-config restart-app /usr/src/redmine
# Plugin Install
	@docker exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production
	@docker exec redmine passenger-config restart-app /usr/src/redmine

.PHONY: down
down:
	@docker-compose down

.PHONY: clean
clean: down
	@sudo rm -fr ./log

.PHONY: distclean
distclean: clean
	@sudo rm -fr ./files
	@sudo rm -fr ./mysql
