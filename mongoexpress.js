const {MongoClient} = require('mongodb');
const app=require('express')()
const cors=require('cors');
const bodyParser=require('body-parser')
let cli;
async function main(){
    
    const uri = "mongodb+srv://Vinay552022:Python552022@cluster0.wsye7pi.mongodb.net/?retryWrites=true&w=majority";
 

    const client = new MongoClient(uri);
 
    try {
        // Connect to the MongoDB cluster
        await client.connect();
        cli=client;
 
        // Make the appropriate DB calls
        await  listDatabases(client);
        app.listen(5000);
        console.log("Listening on port 5000");
    } catch (e) {
        console.error(e);
    } finally {
        // await client.close();
    }
}

main().catch(console.error);
async function listDatabases(client){
    databasesList = await client.db().admin().listDatabases();
 
    console.log("Databases:");
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));
};
app.use(bodyParser.json())
app.use(cors({
    origin:'*'//* for any website

}))
app.get("/", async function(req, res) {
    const result = await cli.db("vinay").collection("students").findOne({ name: "vinay"});

    if (result) {
        console.log(`Found a listing in the collection with the name '${"vinay"}':`);
        console.log(result);
    } else {
        console.log(`No listings found with the name '${"vinay"}'`);
    }
    res.send(`<h1>name=${result.name} rollno=${result.rollno}</h1>`)
  });

 app.post("/TransactionPost",async (req,res)=>{
    let E=req.body;
    let send=await cli.db("SCM").collection("transactions").insertOne(E);
    
 })
 


  app.post("/",async (req,res)=>{
    let E=req.body;
    console.log(E.email,E.password);
    let get=await cli.db("SCM").collection("roles").findOne({ email: E.email });
    console.log(get)
    if(get){
        const {password,role,account} = get;
    
        if(E.password==password){
            res.send({role:role,flag:true,account:account})
        }
        else{
            res.send({flag:false});
        }
        console.log(role)
    }
    else{
    res.send({flag:false})
    }


  })

  app.post("/Transactions",async (req,res)=>{
    let E=req.body;
    console.log(E)
    let get=await cli.db("SCM").collection("transactions").find({ requestId:E[0],mailId:E[1][0]}).toArray();
    
    res.send(get)
    


  })
  app.post("/Register",async(req,res)=>{
    let {UnitId,Password,role,Account}=req.body;
    console.log(role,UnitId)
    let send=await cli.db("SCM").collection("roles").insertOne({"email":UnitId,"password":Password,"role":role,"account":Account})
    res.send("jii");
    console.log(send,"hii")
    
    
  })
  app.post("/RegisterDDST",async(req,res)=>{
    let {DivisionId,Password,role,Account}=req.body;
    
    let send=await cli.db("SCM").collection("roles").insertOne({"email":DivisionId,"password":Password,"role":role,"account":Account})
    res.send("jii");
    console.log(send)
    
    
  })
