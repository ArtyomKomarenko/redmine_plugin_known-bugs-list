class KnownBugsList

  # Получение багов по всем известным проектам.
  # Проекты указываются в настройках.
  # Несуществующие проекты пропускаем.
  # Возвращает массив хэшей
  def get_issues_by_all_projects
    all_issues = []

    projects = Setting.plugin_known_bugs_list[:projects].split(',')

    projects.each do |project|
      begin
        all_issues << get_issues_by_project(project)
      rescue
        #Do nothing
      end
    end

    return all_issues
  end


  private

  # Получение багов по конкретному проекту.
  # Принимает id проекта.
  # Записи преобразуем их ActiveRecord в обычные хэши, чтобы в дальнейшем добавить к ним новый параметр.
  # Возвращает хэш вида { name: string, pages: [ hash ] }
  def get_issues_by_project(project)
    records = get_issues_by_project_from_db(project)

    records = records.map {|elm|
      {
          id: elm[:id],
          tracker_id: elm[:tracker_id],
          status_id: elm[:status_id],
          project_id: elm[:project_id],
          subject: elm[:subject],
      }
    }

    extract_pages records

    pages = group_by_page records

    issues_by_project = {}
    issues_by_project[:name] = Project.find(project)[:name]
    issues_by_project[:pages] = pages

    return issues_by_project
  end

  # Модифицирует переданный хэш, добавляет новый параметр pages: [ string ]
  # Из названия бага забираем все значения в квадратных скобках. Название перезаписываем и рекурсивно
  # прогоняем еще раз, т.к. названий страниц может быть несколько.
  # Если в названии нет значений в квадратных скобках, помещаем условное значение "Прочее"
  def extract_page(record)
    result = record[:subject].match(/(\[[а-яА-ЯЁё\w\s]+\])?(.*)/)

    record[:pages] = [] if record[:pages] == nil

    if result[1] != nil
      record[:pages] << result[1].delete("[]")
      record[:subject] = result[2].lstrip
      extract_page(record)
    elsif record[:pages].size == 0
      record[:pages] << "Прочее"
    end
  end

  # Извлекаем названия страниц циклично из массива хэшей
  def extract_pages(records)
    records.each do |record|
      extract_page(record)
    end
  end

  # Группируем массив хэшей с багами по названию страниц.
  # На выходе получаем массив хэшей вида { name: sting, bugs: [ hash ] }
  def group_by_page(records)
    pages = {}

    records.each do |record|
      record[:pages].each do |page|
        unless pages.has_key? page
          pages[page] = []
        end
        pages[page] << record
      end
    end

    pages = pages.map do |k,v|
      {  name: k, bugs: v  }
    end

    return pages
  end

  # Выборка из базы всех багов в открытых статусах, которые относятся к указанным проектам
  def get_issues_by_project_from_db(project)
     return Issue.where(
        project_id: project,
        status_id: Setting.plugin_known_bugs_list[:statuses].split(','),
        tracker_id: Setting.plugin_known_bugs_list[:trackers].split(',')
     )
  end
end
