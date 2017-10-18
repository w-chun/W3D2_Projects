require_relative 'questions_database'


class Questions < ModelBase
  attr_accessor :title, :body, :user_id

  # def self.all
  #     data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
  #     data.map {|question| Questions.new(question)}
  # end

  def initialize(options)
    @id = options['id']
    @title= options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  # def self.find_by_id(id)
  #   question = QuestionsDatabase.instance.execute(<<-SQL, id)
  #   SELECT
  #     *
  #   FROM
  #     questions
  #   WHERE
  #    id = ?
  #  SQL
  #
  #  return nil if question.empty?
  #  Questions.new(question.first)
  #
  # end

  def self.find_by_title(title)
    question = QuestionsDatabase.instance.execute(<<-SQL, title)
    SELECT
      *
    FROM
      questions
    WHERE
     title = ?
    SQL

    return nil if question.empty?
    Questions.new(question.first)
  end

  def self.find_by_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    WHERE
     user_id = ?
    SQL

    return nil if questions.empty?
    questions.map {|question| Questions.new(question)}
  end

  def replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL

    replies.map {|reply| Replies.new(reply)}
  end

  def user_id
    Users.find_by_id(@user_id)
  end

  # def create
  #   raise "#{self} already in database" if @id
  #   QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
  #     INSERT INTO
  #       questions (title, body, user_id)
  #     VALUES
  #       (?, ?, ?)
  #   SQL
  #   @id = QuestionsDatabase.instance.last_insert_row_id
  # end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLikes.likers_for_question(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end
end
