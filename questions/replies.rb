require_relative 'questions_database'

class Replies < ModelBase
  attr_accessor :question_id, :body, :user_id, :parent_id

  # def self.all
  #     data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
  #     data.map {|reply| Replies.new(reply)}
  # end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @body = options['body']
    @user_id = options['user_id']
    @parent_id = options['parent_id']
  end

  # def self.find_by_id(id)
  #   reply = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #     *
  #   FROM
  #     replies
  #   WHERE
  #    id = ?
  #  SQL
  #
  #  return nil if reply.empty?
  #  Replies.new(reply.first)
  #
  # end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
     question_id = ?
    SQL

    return nil if replies.empty?
    Replies.new(replies.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
     user_id = ?
    SQL

    return nil if replies.empty?
    replies.map {|reply| Replies.new(reply)}
  end

  def self.find_by_parent_id(parent_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
    SELECT
      *
    FROM
      replies
    WHERE
     parent_id = ?
    SQL

    return nil if replies.empty?
    Replies.new(replies.first)
  end

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
    SELECT
      *
    FROM
      questions
    WHERE
     id = ?
    SQL

    return nil if question.empty?
    Questions.new(question.first)
  end

  def parent_reply
    reply = QuestionsDatabase.instance.execute(<<-SQL, @parent_id)
    SELECT
      *
    FROM
      replies
    WHERE
     id = ?
    SQL

    return nil if reply.empty?
    Replies.new(reply.first)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      replies
    WHERE
     parent_id = ?
    SQL

    return nil if replies.empty?
    replies.map {|reply| Replies.new(reply)}
  end

  # def create
  #   raise "#{self} already in database" if @id
  #   QuestionsDatabase.instance.execute(<<-SQL, @question_id, @body, @user_id, @parent_id)
  #     INSERT INTO
  #       replies (question_id, body, user_id, parent_id)
  #     VALUES
  #       (?, ?, ?, ?)
  #   SQL
  #   @id = QuestionsDatabase.instance.last_insert_row_id
  # end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @body, @user_id, @parent_id, @id)
      UPDATE
        replies
      SET
        question_id = ?, body = ?, user_id = ?, parent_id = ?
      WHERE
        id = ?
    SQL
  end


end
