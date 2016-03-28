Bhagavad-Gita Index 

Description:
A web app allowing Users to:
  1. Create a login
  2. Create index's defined by a Topic name, which references a Verse's content.
  3. View index's from all Users
  4. Edit, delete one's own index's
  5. Logout

Database:

  Table Users
    - username
    - email
    - password_digest

  Table Topics
    - name

  Table Verses
    - location
    - content

  Table TopicVerses
    - topic_id 
    - verse_id

  Table UserTopics
    - user_id
    - topic_id

Models:

User
  - has_many topics
  - has_many verses through topics

Topic
  - has_many verses through topic_verses
  - has_many topic_verses

Verse
  - has_many topics through topic_verses
  - has_many topic_verses

TopicVerse
  - belongs_to topic
  - belongs_to verse

UserTopics
  - belongs_to user
  - belongs_to topics


User can get permission to edit community files.

  