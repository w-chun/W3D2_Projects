require_relative 'questions_database'

class QuestionFollow
  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      user_id
    FROM
      question_follows
    WHERE
      question_id = ?
    SQL

    return nil if users[0].empty?
    print users
    users.map {|user| Users.find_by_id(user['user_id'])}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      question_id
    FROM
      question_follows
    WHERE
      user_id = ?
    SQL

    return nil if questions[0].empty?
    questions.map {|question| Questions.find_by_id(question['question_id'])}
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      question_id
    FROM
      question_follows
    GROUP BY
      question_id
    ORDER BY
      count(*) desc
    LIMIT
      ?
    SQL

    return nil if questions.empty?
    questions.map {|question| Questions.find_by_id(question["question_id"])}
  end

  def self.follow_question(user_id, question_id)
    QuestionsDatabase.instance.execute(<<-SQL, user_id, question_id)

    INSERT INTO
      question_follows(user_id, question_id)
    VALUES
      (?, ?);
    SQL
    puts "user #{user_id} followed question #{question_id}"
  end

end
