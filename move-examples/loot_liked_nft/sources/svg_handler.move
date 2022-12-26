module loot_liked_nft::svg_handler {
	use std::vector;

    const ASCII_0: u8 = 48;

    struct SvgGallery has key, store{
        items: vector<SvgResource>,
    }
	struct SvgResource has key, copy, store,drop{
        /// payload of the resource
        id: u64,
        payload: vector<u8>,
	}

    public fun to_string_u8(num: u8):vector<u8> {
        let buf = vector::empty<u8>();
        let i = num;
        let remainder:u8;
        loop{
            remainder = ((i % 10) as u8);
            vector::push_back(&mut buf, ASCII_0 + remainder);
            i = i /10;
            if(i == 0){
                break
            };
        };
        vector::reverse(&mut buf);
        buf
    }

    public fun to_string(num: u64):vector<u8> {
        let buf = vector::empty<u8>();
        let i = num;
        let remainder:u8;
        loop{
            remainder = ((i % 10) as u8);
            vector::push_back(&mut buf, ASCII_0 + remainder);
            i = i /10;
            if(i == 0){
                break
            };
        };
        vector::reverse(&mut buf);
        buf
    }

    public fun build_svg(x: u64, y: u64, fill: vector<u8>, payload: vector<u8>) : vector<u8>{
        let result = vector::empty();
        // https://www.coder.work/article/2553624
        vector::append(&mut result, b"<svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 ");
        vector::append(&mut result, Self::to_string(x));
        vector::append(&mut result, b" ");
        vector::append(&mut result, Self::to_string(y));
        vector::append(&mut result, b"\"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width=\"100%\" height=\"100%\" fill=\"");
        vector::append(&mut result, fill);
        vector::append(&mut result, b"\" />");
        vector::append(&mut result, payload);
        vector::append(&mut result, b"</svg>");
        result
    }

    public fun build_a_line(x: u64, y: u64, payload: vector<u8>) : vector<u8> {
        let result = vector::empty();
        vector::append(&mut result, b"<text x=\"");
        vector::append(&mut result, Self::to_string(x));
        vector::append(&mut result, b"\" y=\"");
        vector::append(&mut result, Self::to_string(y));
        vector::append(&mut result, b"\" class=\"base\">");
        vector::append(&mut result, payload);
        vector::append(&mut result, b"</text>");
        result
    }

    public fun draw_a_circle(
        x: u64, 
        y: u64, 
        r: u64, 
        stroke: vector<u8>,  
        stroke_width: u64, 
        stroke_fill: vector<u8>) : vector<u8> {
        let result = vector::empty();
        vector::append(&mut result, b"circle cx=\"");
        vector::append(&mut result, Self::to_string(x));
        vector::append(&mut result, b"\" cy=\"");
        vector::append(&mut result, Self::to_string(y));
        vector::append(&mut result, b"\" r=\"");
        vector::append(&mut result, Self::to_string(r));
        vector::append(&mut result, b"\" stroke=\"");
        vector::append(&mut result, stroke);
        vector::append(&mut result, b"\" stroke-width=\"");
        vector::append(&mut result, Self::to_string(stroke_width));
        vector::append(&mut result, b"\" fill=\"");
        vector::append(&mut result, stroke_fill);
        vector::append(&mut result, b"\" />");
        result
    }

    public fun draw_a_rec(
        x: u64,
        y: u64,
        width: u64,
        height: u64,
        stroke: vector<u8>,
        stroke_width: u64, 
        stroke_fill: vector<u8>) : vector<u8> {

        let result = vector::empty();
        vector::append(&mut result, b"rect x=\"");
        vector::append(&mut result, Self::to_string(x));
        vector::append(&mut result, b"\" y=\"");
        vector::append(&mut result, Self::to_string(y));
        vector::append(&mut result, b"\" width=\"");
        vector::append(&mut result, Self::to_string(width));
        vector::append(&mut result, b"\" height=\"");
        vector::append(&mut result, Self::to_string(height));
        vector::append(&mut result, b"\" stroke=\"");
        vector::append(&mut result, stroke);
        vector::append(&mut result, b"\" stroke-width=\"");
        vector::append(&mut result, Self::to_string(stroke_width));
        vector::append(&mut result, b"\" fill=\"");
        vector::append(&mut result, stroke_fill);
        vector::append(&mut result, b"\" />");
        result
    }
}
