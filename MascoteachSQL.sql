USE [master]
GO

-- 1. Drop the database if it already exists
IF DB_ID('MascoteachDB') IS NOT NULL
BEGIN
    ALTER DATABASE [MascoteachDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [MascoteachDB];
END
GO

-- 2. Create the new database
CREATE DATABASE [MascoteachDB];
GO

-- 3. Switch to the newly created database before creating tables
USE [MascoteachDB]
GO

-- 4. Create Tables
CREATE TABLE Game_Templates (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    js_bundle_url VARCHAR(MAX) NOT NULL,
    thumbnail_url VARCHAR(MAX),
	is_deleted BIT NOT NULL
);

CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Teacher', 'Parent','Student','Admin')),
    subscription_tier VARCHAR(50) NOT NULL CHECK (subscription_tier IN ('Freemium', 'Premium')),
    documents_processed INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
	is_deleted BIT NOT NULL
);

CREATE TABLE Documents (
    id INT IDENTITY(1,1) PRIMARY KEY,
    teacher_id INT NOT NULL,
    file_url VARCHAR(MAX) NOT NULL,
    uploaded_at DATETIME DEFAULT GETDATE(),
	is_deleted BIT NOT NULL,
    CONSTRAINT FK_Documents_Users FOREIGN KEY (teacher_id) REFERENCES Users(id)
);

CREATE TABLE Quizzes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    document_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('AI_Drafted', 'Teacher_Approved')),
    created_at DATETIME DEFAULT GETDATE(),
	is_deleted BIT NOT NULL,
    CONSTRAINT FK_Quizzes_Documents FOREIGN KEY (document_id) REFERENCES Documents(id)
);

CREATE TABLE Questions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    quiz_id INT NOT NULL,
    question_text NVARCHAR(MAX) NOT NULL,
    question_type VARCHAR(50) DEFAULT 'MultipleChoice', 
    is_deleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Questions_Quizzes FOREIGN KEY (quiz_id) REFERENCES Quizzes(id)
);

CREATE TABLE Options (
    id INT IDENTITY(1,1) PRIMARY KEY,
    question_id INT NOT NULL,
    option_text NVARCHAR(MAX) NOT NULL,
    is_correct BIT NOT NULL DEFAULT 0, 
    is_deleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Options_Questions FOREIGN KEY (question_id) REFERENCES Questions(id)
);

CREATE TABLE Live_Sessions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    teacher_id INT NOT NULL,
    quiz_id INT NOT NULL,
    template_id INT NOT NULL,
    game_pin VARCHAR(10) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Waiting', 'Active', 'Ended')),
    created_at DATETIME DEFAULT GETDATE(),
	is_deleted BIT NOT NULL,
    CONSTRAINT FK_LiveSessions_Users FOREIGN KEY (teacher_id) REFERENCES Users(id),
    CONSTRAINT FK_LiveSessions_Quizzes FOREIGN KEY (quiz_id) REFERENCES Quizzes(id),
    CONSTRAINT FK_LiveSessions_GameTemplates FOREIGN KEY (template_id) REFERENCES Game_Templates(id)
);

CREATE TABLE Session_Participants (
    id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    student_name NVARCHAR(255) NOT NULL,
    total_score INT DEFAULT 0,
	is_deleted BIT NOT NULL,
    CONSTRAINT FK_Participants_LiveSessions FOREIGN KEY (session_id) REFERENCES Live_Sessions(id)
);
GO
