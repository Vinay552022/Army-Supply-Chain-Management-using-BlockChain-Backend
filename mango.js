const {MongoClient} = require('mongodb');
async function main(){
    /**
     * Connection URI. Update <username>, <password>, and <your-cluster-url> to reflect your cluster.
     * See https://docs.mongodb.com/ecosystem/drivers/node/ for more details
     */
    const uri = "mongodb://127.0.0.1:27017/";
 

    const client = new MongoClient(uri);
 
    try {
        // Connect to the MongoDB cluster
        await client.connect();
 
        // Make the appropriate DB calls
        await  listDatabases(client);
        await createListing(client,{
            name:"vinaydb",
            age:20
        })

       await createListings(client,[{
        name:"nishanth",
        age:19
    },
    {
        name:"mani",
        age:20
    }
])
    await findOneListingByName(client,"vinaydb" )
    await updateListingByName(client, "mani", {age:19 });
    await deleteListingByName(client, "nishanth");

 
    } catch (e) {
        console.error(e);
    } finally {
        await client.close();
    }
}

main().catch(console.error);
async function listDatabases(client){
    databasesList = await client.db().admin().listDatabases();
 
    console.log("Databases:");
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));
};
async function createListing(client,newListing){
    const result = await client.db("vinaydb").collection("students").insertOne(newListing);
    console.log(`New listing created with the following id: ${result.insertedId}`);

}
async function createListings(client,newListings){
    const result = await client.db("vinaydb").collection("students").insertMany(newListings);
    console.log(`${result.insertedCount} new listing(s) created with the following id(s):`);
    console.log(result.insertedIds);  

}
async function findOneListingByName(client, nameOfListing) {
    const result = await client.db("vinaydb").collection("students").findOne({ name: nameOfListing });

    if (result) {
        console.log(`Found a listing in the collection with the name '${nameOfListing}':`);
        console.log(result);
    } else {
        console.log(`No listings found with the name '${nameOfListing}'`);
    }
}   

async function updateListingByName(client, nameOfListing, updatedListing) {
    const result = await client.db("vinaydb").collection("students")
                        .updateOne({ name: nameOfListing }, { $set: updatedListing });

    console.log(`${result.matchedCount} document(s) matched the query criteria.`);
    console.log(`${result.modifiedCount} document(s) was/were updated.`);
}


async function deleteListingByName(client, nameOfListing) {
    const result = await client.db("vinaydb").collection("students")
            .deleteOne({ name: nameOfListing });
    console.log(`${result.deletedCount} document(s) was/were deleted.`);
}