# Example HLD

## Contents

* [Overview](##-Overview)
* [Requirements](##-requirements)
* [API](##-api) 
* [Security](##-security) 
* [Deployement](##-deployement) 
* [Backward Compatibility](##-backward-compatibility) 


## Overview 
As part of improving our preformace and stability we decided to wrapp our Elastic Search with a microservice that will manage all reading and writing requests. 
The added benefit of such microservice, is that it allows us to better manage R&W throtteling, and archive indexes.


## Requirements
* Create a new micro service Elastic search
* API for writing new varaints to an index
* API for reading variants from an index
* API for deleting a case from index
* API for throtteling 
* Cost optimizations by archiving old indexes


## API 

### POST /varaints/EMG123456
create a new  



![diagram](http://www.plantuml.com/plantuml/svg/1S513WCX20NGVK_H7g2oxsse4YKHDV3997FwUU-ZgyviaZxV0pZn8tA-IbUC_6U8rxqW2wLk8pR5LsvdWWJ8E21EJRaxMpapxVK0)
test
