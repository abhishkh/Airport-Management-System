#### DATABASE MANAGEMENT AND DATABASE DESIGN - AIRPORT MANAGEMENT SYSTEM

## Background:
Today, airport management systems are highly sophisticated, interconnected ecosystems that play a crucial role in ensuring the safe, efficient, and passenger-friendly operation of airports worldwide. 
These systems have evolved significantly over the decades to keep pace with technological advancements, changing regulations, and the increasing demands of modern air travel. 
Managing an airport efficiently and securely requires accurate data collection, storage, and retrieval. An Airport Management System can streamline operations, enhance security, and improve passenger experiences.

## Objective:
**Efficiency**: Streamlining airport operations to minimize delays, optimize resource allocation,
and enhance overall efficiency.

**Passenger Experience:** Providing a seamless and pleasant travel experience through efficient check-in processes, baggage handling, and information services.


**Safety and Security:** Implementing robust security measures to safeguard against potential threats and that will ensure the safety of all airport users.

**Data Management**: Capturing, storing, and analyzing data related to flights, passengers, and baggage to improve decision-making and enhance services.

**Resource Management:** Efficiently managing airport resources, such as runways, gates, baggage carousels, and check-in counters, to maximize utilization.

**Compliance:** Ensuring that the airport complies with international aviation regulations and safety standards.

**Integration:** Integrating various airport systems and technologies, including baggage handling systems, passenger information displays, and security systems, to create a cohesive and interconnected environment.
 
 
 ## Scope:
The scope of an Airport Management System is to optimize baggage tracking and management, streamline flight scheduling and execution, provide passenger-centric services that prioritize swift and trouble-free check-ins,
maintain robust traveler data for personalized experiences, and enforcing rigorous safety and security measures to protect both travelers and airport facilities. This system allows for real-time monitoring, reporting,
and informed decision-making while ensuring adherence to regulatory standards, ultimately elevating the overall passenger experience. Its significance is especially pronounced in ensuring the smooth and secure operation of medium-sized airports.


What’s Included:
Object Type Quantity or Comments Yes/No
Views 6 This includes - Baggage Tracking, Passenger Bookings,
           
Tables
13
These tables include - Airport, Employee, Passenger, Ticket, Airline, Flight, Baggage, Booking, Cancellation, Immigration Clearance, Baggage Tracking, Passenger Audit, and Flight Status Audit Table.
   
Current Flight Status, Airline Max Revenue, Check Availability, and Employee Airport Visualization.
Table Level Check Constraint
4
Table Employee and Table Passenger - sex check; Ticket Table - class check; Flight Table - Status Check; Baggage Table - size check
Computed Column based on UDF
1
This includes - Calculate Age
Non-Clustered Indexes
3
Non-Clustered index on Booking Table, Employee Table and Baggage Table.
Stored Procedures
4
These include - Handle Baggage, Manage Booking Cancellation, Calculate Total Luggage Weight, Update Flight Status
User Defined Functions (UDF)
2
These include - Calculate Total Flight Revenue and Convert Ticket Price.
DML Triggers
Column Data Encryption
BI Data Visualization
GUI for CRUD Operations (optional)
Other
1
1 Yes No
-
Audit Passenger Update, and Audit Flight Status Changed For Password Field in Passenger Table.
Created Pie Charts and Bar Graphs for data visualization.
- -
               
