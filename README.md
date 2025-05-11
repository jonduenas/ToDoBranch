# To-Do Project README

### Requirements:

* Use MVVM architectural pattern
* Focus on iPhone compatibility exclusively. Support for other device types is not required.
* Use standard iOS design components wherever possible. Nothing fancy required!
* Allow adding a to-do with user-provided name
* Allow deleting a to-do
* Allow a user to fetch (via async/await) and populate demo to-dos via this [URL](https://jsonplaceholder.typicode.com/todos).
* Use Core Data to persist to-dos to disk
* Use as much SwiftUI as possible
* Include unit tests to cover key functionalities

### Implementation Notes

The view layer is 100% SWiftUI. I attempted to mimic a lot of the basic Apple Reminders app UI intentionally. But obviously this is not as fully fleshed out of an app.

The app uses general MVVM architecture and utilizes a repository pattern for the model layer. The repository abstracts the source of the data and exposes basic CRUD operations as well as an array of loaded models. The array of models is kept in sync with the Core Data database using NSFetchedResultsController. It then uses the new Observable macro to allow automatic view updates whenever the array changes. I also decided to make this MainActor isolated -- the main reason is that the models being NSManagedObjects prevents them from being Sendable, so this simplifies working with Core Data contexts and threads and prevents accessing these models from anything other than the main thread, and allows me to use a single context without having to manage multiple background contexts.

The repository accesses a Core Data layer (the PersistenceController) for loading and storing changes to the local database. This PersistenceController is largely based on the default Xcode template for adding Core Data, for the sake of saving time. It notably does not contain any sort of real error handling. But it does allow creating in-memory stores for the purpose of testing and the demo mode.

The networking layer was also an area I decided to spend less time on. There is a simple service protocol used that sends the fetch request, verifies the response, and decodes the data. I utilized generics to provide the most flexibility. These protocols could be easily used to fetch any kind of model defined as conforming to the Fetchable protocol. This also allowed for easy testing with a simple stub implementation of the service.

The main goal I spent my time on was making the repository work in 3 different "modes": 

1. Live with writing to the database
2. Live with writing to memory only
3. Demo with seeded data from the network request and writing to memory.
  
All that is required is that the repository be initialized with the appropriate parameters, and from that point on, anything that uses the repository has no knowledge of where the data comes from or where it is being saved. The best demonstration of this is in how I implemented the demo mode. The app launches in live mode, but when the "Try Demo" button is tapped, it shows a sheet that loads the demo data. Because of the repository pattern, the demo view can use the same view model and views with no changes other than at their initial initialization. So demo mode can share all the same logic as live mode. I went with this kind of demo mode because it shows off the flexibility of the repository, but it also maintains the user's existing data.

### Testing

The view model and repository both have unit tests that cover key functionality. I utilized the new Swift Testing framework, though XCTest would have been just as capable.

### Limitations

Given the project requirements and time constraints, a number of compromises were made that I'd like to call out.

#### Error handling

I didn't include any real error handling other than printing the error. In general I still tried to utilize throwing functions as much as possible to propogate errors upwards. With more time and requirements on how to present errors to a user, the view model would catch the errors and format them in a user-friendly way to inform the user as needed. Additionally, things like retrying or adding a reload/refresh, or some other way to recover from an error would likely be considered.

#### Sorting and Filtering

Since it wasn't part of requirements, I left this out. But 

#### Core Data and Sendable

As I stated in the section on the repository, Core Data uses NSManagedObject for models. These are reference types and are thus, not Sendable. This in my experience has always made working with Core Data (and SwiftData) painful. If I wanted to add background processing of models, I would have to maintain strict access to the models to keep them isolated to the background thread and context it was loaded on. You end up needing an object that handles background tasks, and a separate one for the view layer isolated to the MainActor, and they can only communicate by passing Sendable data back and forth, like a NSManagedObjectID. Implementing this would already require a significant amount of time and code, hence I'm calling it out here as a way to improve this, but I simply would not have the amount of time needed to make this robust.

One strategy that I've found can be very effective (though it has its own benefits and downsides) is to add an additional layer of abstraction over Core Data models by using the NSManagedObjects loaded by Core Data to create mirror versions using Swift structs instead. These being value types, they are very easy to make Sendable, and thus, you can have your Core Data layer working in the background and sending these struct versions out to your view/view model layer. The challenge with this is creating a robust system that can keep things in sync moving back and forth between the struct version and the NSManagedObject versions. It can be a lot of boiler plate code to make it work, but it has the big benefit of never needing to worry about how to get a model from a background thread to the main thread or vice versa.
