require_relative "questions_database"
require_relative "model_base"

class Users < ModelBase
  attr_accessor :fname, :lname


  # def self.all
  #     data = QuestionsDatabase.instance.execute("SELECT * FROM users")
  #     data.map {|user| Users.new(user)}
  # end

  def initialize(options)
    @fname = options['fname']
    @lname = options['lname']
    @id = options['id']
  end

  # def self.find_by_id(id)
  #   user = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #     *
  #   FROM
  #     users
  #   WHERE
  #    id = ?
  #  SQL
  #
  #  return nil if user.empty?
  #  Users.new(user.first)
  #
  # end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
     fname = ? AND lname = ?
    SQL

    return nil if user.empty?
    Users.new(user.first)
  end

  def authored_questions
    Questions.find_by_user_id(@id)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end

  # def create
  #   raise "#{self} already in database" if @id
  #   QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
  #     INSERT INTO
  #       users(fname, lname)
  #     VALUES
  #       (?, ?)
  #   SQL
  #   @id = QuestionsDatabase.instance.last_insert_row_id
  # end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ? , lname = ?
      WHERE
        id = ?
    SQL
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLikes.liked_questions_for_user_id(@id)
  end

  def average_karma
    number = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      CAST(COUNT(question_likes.user_id) AS FLOAT) / COUNT(DISTINCT(questions.id))
    FROM
      questions
    LEFT JOIN
      question_likes
      ON questions.id = question_likes.question_id
    WHERE
      questions.user_id = ?
    SQL
    number.first["AVERAGE"]
  end


end
