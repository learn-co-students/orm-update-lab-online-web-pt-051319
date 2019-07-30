require_relative "../config/environment.rb"

class Student

	attr_accessor :name, :grade, :id

	def initialize(name, grade, id = nil)
		@name = name
		@grade = grade
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS students (
				id INTEGER PRIMARY KEY,
				name TEXT,
				grade  INTEGER
			)
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute('DROP TABLE IF EXISTS students')
	end

	def self.create(name, grade, id = nil)
		Student.new(name, grade, id).tap{ |student| student.save }
	end

	def self.new_from_db(row)
		self.create(row[1], row[2], row[0])
	end

	def self.find_by_name(name)
		self.new_from_db(DB[:conn].execute('SELECT * FROM students WHERE name = ?', name)[0])
	end

	def save
		if self.id
			self.update
		else
			DB[:conn].execute('INSERT INTO students (name, grade) VALUES (?,?)', self.name, self.grade)
			self.id = DB[:conn].execute('SELECT id FROM students ORDER BY id LIMIT 1').flatten[0]
		end
	end

	def update
		sql = <<-SQL
			UPDATE students
			SET name = ?, grade = ?
			WHERE id = ?
		SQL
		DB[:conn].execute(sql, self.name, self.grade, self.id)
	end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
