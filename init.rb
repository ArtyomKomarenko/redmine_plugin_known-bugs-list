Redmine::Plugin.register :known_bugs_list do
  name 'Known Bugs List'
  author 'Artyom Komarenko'
  description 'Плагин для просмотра списка известных и нерешенных ошибок, сгруппированных по названию экранов/страниц.
Для этого нужно в начале названия бага указать в квадратных скобках названия экранов: [Экран][Экран] Название
Перед использованием нужно установить значения идентификаторов проектов, трекеров и статусов в настройках плагина'
  version '1.0'
  author_url 'artyom.komarenko@mail.ru'
  menu :project_menu, :known_bugs_list, { controller: 'known_bugs_list', action: 'index' }, caption: 'Известные баги', param: :project_id
  project_module :known_bugs_list do
    permission  :view_bugs, known_bugs_list: :index
  end
  settings default: {
      trackers: '6,10,24,25', #critical bug, bug, bug mob, critical bug mob
      projects: '110,111,112,113', #mobile, android, ios, курьер
      statuses: '17, 19, 47', #dev new, dev pause, backlog
  }, partial: 'settings/known_bugs_list_settings'
end
