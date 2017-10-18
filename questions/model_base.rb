class ModelBase

  def self.find_by_id(id)
    table = self

    item = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{table}
    WHERE
     id = ?
   SQL

   return nil if item.empty?
   self.new(item.first)
  end

def self.all
  table = self

  data = QuestionsDatabase.instance.execute("SELECT * FROM #{table}")
  data.map {|name| self.new(name)}
end

def create
  table = self.class
  variables = self.instance_variables[0..-1]
  variables.delete(:@id)

  values = "\'" + variables.map {|variable| self.instance_variable_get("#{variable}") }.join("\', \'")+"\'"
  fname, lname = values
  variables = variables.map! {|variable| variable.to_s[1..-1]}.join(", ")
  variables = "("+variables + ")"
  raise "#{self} already in database" if @id
  QuestionsDatabase.instance.execute(<<-SQL)
    INSERT INTO
      #{table} #{variables}
    VALUES
      (#{values})
  SQL
  @id = QuestionsDatabase.instance.last_insert_row_id
end

def first_instance
  a = self.instance_variables[0]
  return self.instance_variable_get("#{a}")
end

end
