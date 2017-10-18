class QuestionLikes

  def self.likers_for_question(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)

      SELECT
        users.fname, users.lname, question_id
      FROM
        question_likes
      JOIN
        users
      ON
        users.id = question_likes.user_id
      WHERE
        question_id = ?
      SQL
    return nil if users.empty?
    users.map {|user| Users.new(user) }


  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)

      SELECT
        count(*) as likes
      FROM
        question_likes
      WHERE
        question_id = ?
      SQL
    likes.first["likes"]
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        title, body, questions.user_id
      FROM
        question_likes
      JOIN
        questions
      ON
        questions.id = question_likes.question_id
      WHERE
        questions.user_id = ?
    SQL
    return nil if questions.nil?
    questions.map {|question| Questions.new(question)}

  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        title, body, questions.user_id
      FROM
        question_likes
      JOIN
        questions
      ON
        questions.id = question_likes.question_id
      GROUP BY
        question_id
      LIMIT
        ?
      SQL

    questions.map {|question| Questions.new(question)}
  end

end
