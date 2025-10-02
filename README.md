# CheckUpPlus Capstone Project
<p align="center">
<img src="https://img.shields.io/badge/Status-UI_Complete_%7C_ML_Ready-007EC6?style=for-the-badge&logo=appveyor" alt="Project Status Badge">
<img src="https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Frontend Badge">
<img src="https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi" alt="Backend Badge">
</p>

🎯 **Project Overview:** Reducing ER Strain Through Smart Triage

CheckUpPlus is a multi-platform mobile application designed to address the growing issue of Emergency Room (ER) overcrowding in the Canadian healthcare system. Many individuals seek ER treatment for non-critical issues due to a lack of immediate, clear guidance on appropriate care options.
This project proposes a smart triage solution that leverages Machine Learning (ML) to assess medical severity from user inputs (symptoms or images). By providing patients with real-time information on nearby healthcare options, including walk-in clinics, urgent care centres, and virtual consultations, CheckUpPlus aims to:

  * Reduce Unnecessary ER Visits: Directing non-critical cases to more appropriate facilities.
  * Improve Healthcare Accessibility: Providing clear, immediate guidance on care.
  * Enhance Patient Satisfaction: Minimizing wait times and stress for patients.

✨ **Current Features and Milestones:**
The project is built on Flutter for cross-platform UI and is establishing a robust FastAPI backend for the machine learning model.

📱 **User Interface (UI/UX) & Onboarding:**
The core application shell and user flows have been successfully structured and implemented.

  * Complete Authentication Flow: The user registration and login process is fully functional, ensuring secure access to the application.
  * First-Time Onboarding: A set of one-time onboarding pages is complete, providing a smooth introduction to the app's features for new users.
  * Main Screen Structure: Basic, non-functional UI/UX structures are defined for the primary navigation tabs:
  * Home Page: Includes placeholders for key features like Search, Doctor Speciality Listings, Nearby Clinics, and a prominent AI Triage Call-to-Action (CTA).
  * Booking/Appointment Pages: Features basic UI for organizing appointments into Upcoming, Completed, and Canceled/Missed sections.
  * Chat Page: A foundational UI is ready, featuring a title, text input box, send button, and display areas for both Bot/AI and User messages.

💻 **Backend:**
  * The foundation for the critical Machine Learning backend is established, and data communication standards are defined.
  * Machine Learning Triage Model: The core ML severity assessment logic is developed in Python and is ready to be containerized and exposed as a service.
