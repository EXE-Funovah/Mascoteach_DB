CREATE TABLE Game_Templates (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    js_bundle_url VARCHAR(MAX) NOT NULL,
    thumbnail_url VARCHAR(MAX)
);

CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Teacher', 'Parent','Student')),
    subscription_tier VARCHAR(50) NOT NULL CHECK (subscription_tier IN ('Freemium', 'Premium')),
    documents_processed INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE Documents (
    id INT IDENTITY(1,1) PRIMARY KEY,
    teacher_id INT NOT NULL,
    file_url VARCHAR(MAX) NOT NULL,
    uploaded_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Documents_Users FOREIGN KEY (teacher_id) REFERENCES Users(id)
);

CREATE TABLE Quizzes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    document_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('AI_Drafted', 'Teacher_Approved')),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Quizzes_Documents FOREIGN KEY (document_id) REFERENCES Documents(id)
);

CREATE TABLE Questions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    quiz_id INT NOT NULL,
    question_text NVARCHAR(MAX) NOT NULL,
    options NVARCHAR(MAX) NOT NULL,
    correct_answer NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_Questions_Quizzes FOREIGN KEY (quiz_id) REFERENCES Quizzes(id)
);

CREATE TABLE Live_Sessions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    teacher_id INT NOT NULL,
    quiz_id INT NOT NULL,
    template_id INT NOT NULL,
    game_pin VARCHAR(10) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Waiting', 'Active', 'Ended')),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_LiveSessions_Users FOREIGN KEY (teacher_id) REFERENCES Users(id),
    CONSTRAINT FK_LiveSessions_Quizzes FOREIGN KEY (quiz_id) REFERENCES Quizzes(id),
    CONSTRAINT FK_LiveSessions_GameTemplates FOREIGN KEY (template_id) REFERENCES Game_Templates(id)
);

CREATE TABLE Session_Participants (
    id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    student_name NVARCHAR(255) NOT NULL,
    total_score INT DEFAULT 0,
    CONSTRAINT FK_Participants_LiveSessions FOREIGN KEY (session_id) REFERENCES Live_Sessions(id)
);