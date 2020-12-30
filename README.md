# Universe-Docs
Universe Docs

Database files are missing! Anybody who copied my previous source code you should have database files! Can you send it to me at kumar.muthaiah@yahoo.com, else i need to do lots of effort! I've a old copy of database files! If nobody gives the latest database files, then I will try to fix the old one and put here, but it will take time! 

Required developers please contact me kumar.muthaiah@yahoo.com

Other repositories needed to run this project:
1. Universe Docs Brain (https://github.com/universedocs/Universe-Docs-Brain)
2. Universe Docs Web (https://github.com/universedocs/Universe-Docs-Web)

Universe Documents (Universe Docs) (I've started this project from October 2018, after i resigned from a company to do self employement. After deciding to not work as slave and follow my dreams!)

This project is partially done! Once completed it will benefit! 

What is this project? It is a WYSIWYG document editor, no code software, application store, document as a service, data repository, training tool, book library! Each document items in the document are searchable and added to the document! The document items are categorised hierarchially for easier understanding! It allows to create applications using set of documents! Document item search can be enabled or disabled! This application gathers data like human! Humans in brain they used to categorise informations they perceive and while writing a document or expressing things they use the categorised information in mind (document items)!

A Document item can be a text, photo, video, animation, button, link, upload document, download document or share button!If you tap or click a document item in document then other items of the same category shows and you can change it! If you click a photo other photos of same category shows up!

Universe docs brain is a web service that generates the view for the document, based on the device! The view is displayed in the client app "Universe Docs". The client app can be running in any platform the user desires! The view model is platform independent! Universe docs brain is nothing but set of neurons that is doing specific tasks!

Looks like a disadvantage but not like that:

1. Since each document item or text is searched and added to the document, it will be slow. Our brain is designed to handle things slowly and it is better to do things slowly! We humans do everything fast and is a problem! It doesn't mean it is designed to delay user, but we can make the search faster using search alogrithms!
2. We need to devote time to cateogrise document items of each document, but the time we spend for it benefits us later! Since the document is categorised it is easy to understand! It is used to get graph details of each document item from document!

How it compares to Google docs, Apple pages, microsoft word?

1. Each item (text, photo,etc.,) in the document are categorised and easy to parse, validate, filter, remote access/modify! For example by robot which is learning a recipe and modifies the document!
2. Each item (text, photo,etc.,) in the document are categorised while document is created / pre categorised, and no need extra processing by natural language processing!
3. The document follows a model. Graph is used for now. Later it can include any other model!
4. For deleting/copying a line/word/sentence/node just invoke a command no need to highlight and do it!
5. Avoids duplicates.
6. Provides service to manipulate documents from remote. For example a robot can manipulate document from distance or through wireless communcation!
7. Easy to find detials of each document items like description, further details, translations, meaning, hierarchy, etc., from the document itself! That details can be filtered based on specific document type!
8. Brings all documents and applications in central place like a book library, that is easy to search, interact between them and access
9. The document items can be used as a thing for changing the text in document to other one easily

What are the document types it can have?

1. Training document (can be any training document! For each training document there is a separate document type)
2. Food recipe document
3. Shopping list document (along with the food recipe handles food recipes)
4. Task document (used in software development)
5. ingredient document (contians all the ingredeints for a food recipe)
6. vector drawing document with event handling (Can be used for teaching. Can be used as board in school. Can be embedded in a interactive training document for home school. Document items can be searched and added into this document while teaching. Can use pencil to draw lines, rectangle and other shapes to explain things!)
7. shopping list, shoping item detail, checkout and payment gateway documents (use to shop anything)
8. personal page document (celebraties personal page, accessed through app link)
9. requirements document (used in software development)
10. design document (used in software development)
11. calendar document (used by software developers, individuals, etc.,) The calender can contain reference to food recipe, task, requirement, design, issue, alogrithm or any other type of document! Which allows users to plan one or more documents for a day or month or time or whatever!
12. issue document (used in software development)
13. algorithm document (used in software development. Extracts the comments from source code in hierarchial format so that user no need to see source code to understand the logic)
14. source code document ( can be embeedded in software trainings)

UI controls

1. text
2. photo/video/animation
3. link (document, website, email, phone)
4. upload document (use in trainings to upload a home work document)
5. download document (used to download source codes for a software training)
6. share (facebook, twitter, instagram, etc.,)
7. table
8. graph (for adding nested contents in graphical format)
9. vector diagram (for embedding in school training books)

UI interfaces

1. document map - graphically access documents
2. option map - all the options are displayed through this
3. toolbar
4. object controller

In progress / to do / done things:

1. making every user interface editable using document
2. If a title of a document renames all the refered places renames
3. if a document item name changes then all refered document renames
4. Import one or more lines from a web page or a document as a document items
5. Import a CSV file to create document items
6. import a csv or excel file to create document item and detail document
7. Make the search process fast by indexing the document items
8. Make the documents presentable in presentation mode. This presentation will look like a video! Handles presentation in any language, where as a video done by Udemy is handling only one language! Even can generate video from set of documents (https://github.com/dev-labs-bg/swift-video-generator)! The text in the document are spoken by Text-To-speech by google api! Some words can be technical and not english (for example: "xcodeproj" can be said as "x code project") and to pronounce correctly we have to change pronounciation based on document type! The text in the document are translated using google translate api! In future text-to-speech can immitate each individual and no need actual human! Robots will train us and humans just learn! The separate presentation document can use templates and can refer contents of the main document! Don't duplicate things in presentation document and difficult to maintain!
9. The user can search what documents are using a specific document item. For example in food recipe documents the user can search for an ingredient docuemnt item!
10. The new text added is automatically categorised in to grammar item based on oxford dictionary api
11. Ability to see a graphical representation of a document item. For example you can know a fruit or vegetable belong to which species or family! It will show a graph to explain!
12. Move most collections to the document graph model instead of json in mongodb! This includes document, human profile, company profile, application profile, user name password authentication, security token pin, email pin verification, mailjet parameters, etc., If we move it is easy to manage from the device itslef instead of going to database!
13. import one or more photos as document items using the file name as the photo name
14. Import document items by scannig image through OCR or taking photo from video and use OCR. Can use machine learning
15. Can capture information like human on the fly in the videos to add document items
16. While adding new text in document it can be categorised by allowing user to search categories and then add to that category or create new categories and add to that!
17. The texts are in default format! Each level is following a colour! We can add formating to each ui controls to make it beautiful!
18. Ability to collapse/expand graph nodes
19. Ability to cut/copy/paste through server or client
20. Ability to find and replace
21. Ability to redo or undo
22. A document or part of document can be imported in a document. On change at source changes in target also (Reference)

Brain functions:

1. Neurons can be moved to client or server as the user desires, while building the project! A client cannot hold all the neurons in that case server has those neurons! If the neurons are in client can do offline things! If neuron is in server can do online things! Same neuron code is used for client and server! Server is a web service!
2. All the neurons can access the data using a single database server
3. We can have one or more duplicate brains to handle large number of users, but accessing single database server or separate database server
4. We can view what neurons are executing in a brain
5. Since neuron accept single input all the input data can be validate before using

Known issues:

1. The udcdocument is not changing the document name when document title is changed. Also the language title is not changing!
2. Some document items are not in natural order
3. Some other issues are randomly coming need to resolve

Some documents you can view in document map (the left view. search by typig in search bar) to check how document items look like:

1. food ingredient
2. food ingredient unit
3. grammar
4. country
5. volume unit
6. temperature unit
7. gas stove mark etc.,

Some document items are not linked to document map yet so you need to use the document id in udcdocument and put manually in view code to view it!

Future prospects:

1. No code software - For this to happen we need to automate the whole application and make it programmable from client device itself! Application already designed to be no code software in future!
2. Document as a service (Daas) - Used to modify a document from a device. For example plant IoT device residing in home. The univese docs brain will run in Linux and will be running in users home.
3. Interactive education books - needs vector drawing document, source code document, training document
4. Printable books that can be sold - Need to follow some templates
5. Add more platforms like Windows 10, Android, Linux, etc., since only view is changing. Funcitonality remains same. Since functionality is written in swift only swift supporting platforms can have offline functionality! This also can change since Swift programming language is now written for more operating systems like windows 10, amazon linux, centos, etc., So the nueron code can reside in both client and server for all operating system so one code can serve for all!

Objectives:

1. To make everything manageable in device itself using documents. User no need to manage database or deployment server!
2. I will not use web application for this since it creates suffering! Native application is the natural thing that takes care of the user! We have lots of duplicate operating system, programming languages, etc., it is not good and we need to support a single one! If we support single one we can cooperate and make it better for whole humanity!
