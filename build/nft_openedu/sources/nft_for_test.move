module openedu::nft {

    use sui::object;
    use std::string;
    use sui::url;
    use sui::tx_context;
    use sui::transfer;
    
    struct EDUNFT has key, store{
        id: object::UID,
        name: string::String,
        link: url::Url,
        image_url: url::Url,
        description: string::String,
        creator: string::String
    }

    public(friend) fun mint(_name: vector<u8>, _link: vector<u8>, _image_url: vector<u8>, _description: vector<u8>, _creator: vector<u8>, ctx: &mut tx_context::TxContext):EDUNFT{
        EDUNFT {
            id: object::new(ctx),
            name: string::utf8(_name),
            link: url::new_unsafe_from_bytes(_link),
            image_url: url::new_unsafe_from_bytes(_image_url),
            description: string::utf8(_description),
            creator: string::utf8(_creator)
        }
    }

    public fun update_name(nft: &mut EDUNFT, name: vector<u8>) {
        nft.name = string::utf8(name);
    }

    public fun update_link(nft: &mut EDUNFT, link: vector<u8>) {
        nft.link = url::new_unsafe_from_bytes(link);
    }

    public fun update_image_url(nft: &mut EDUNFT, image_url: vector<u8>) {
        nft.image_url = url:: new_unsafe_from_bytes(image_url);
    }

    public fun update_description(nft: &mut EDUNFT, description: vector<u8>) {
        nft.description = string::utf8(description);
    }

    public fun update_creator(nft: &mut EDUNFT, creator: vector<u8>) {
        nft.creator = string::utf8(creator);
    }

    public fun get_name(nft:&EDUNFT): &string::String {
        &nft.name
    }
    
    public fun get_link(nft:&EDUNFT): &url::Url {
        &nft.link
    }
    
    public fun get_image_url(nft:&EDUNFT): &url::Url {
        &nft.image_url
    }
    
    public fun get_description(nft:&EDUNFT): &string::String {
        &nft.description
    }
    
    public fun get_creator(nft:&EDUNFT): &string::String {
        &nft.creator
    }
    #[test_only]
    public fun mint_for_test(
        name: vector<u8>,
        link: vector<u8>,
        image_url: vector<u8>,
        description: vector<u8>,
        creator: vector<u8>,
        ctx: &mut tx_context::TxContext
    ):EDUNFT {
        mint(name,link,image_url, description, creator, ctx)
    }
}
#[test_only]
module openedu::nft_for_test {
    use openedu::nft::{Self, EDUNFT};
    use sui::test_scenario as ts;
    use sui::transfer;
    use std::string;
    use sui::url;

    #[test]
    fun mint_test() {
        let addr1 = @0xA;
        let addr2 = @0xB;

        let scenario = ts::begin(addr1); 
        let nft = nft::mint_for_test(
                b"name",
                b"link",
                b"image_url",
                b"description",
                b"creator",
                ts::ctx(&mut scenario)
            );
        transfer::public_transfer(nft, addr1);
        
        ts::next_tx(&mut scenario, addr1);
        let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
        transfer::public_transfer(nft, addr2);

        ts::next_tx(&mut scenario, addr2);
        let nft = ts::take_from_sender(&mut scenario);

        nft::update_name(&mut nft, b"new name");
        assert!(*string::bytes(nft::get_name(&mut nft))==b"new name",0);

        nft::update_link(&mut nft, b"new link");
        assert!(*nft::get_link(&mut nft)==url::new_unsafe_from_bytes(b"new link"),0);

        nft::update_image_url(&mut nft, b"new image url");
        assert!(*nft::get_image_url(&mut nft)==url::new_unsafe_from_bytes(b"new image url"),0);

        nft::update_description(&mut nft, b"new description");
        assert!(*string::bytes(nft::get_description(&mut nft))==b"new description",0);

        nft::update_creator(&mut nft, b"new creator");
        assert!(*string::bytes(nft::get_creator(&mut nft))==b"new creator",0);

        ts::return_to_sender(&mut scenario, nft);

        ts::end(scenario);
        
    }
}