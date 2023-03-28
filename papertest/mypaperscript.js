console.log("Hello?");

paper.install(window);

function constructVis() {
        
    paper.setup("myCanvas");
    var rivercoords = [
        {x:400, y:800},
        {x:400, y:757},
        {x:415, y:691}, 
        {x:454, y:665}, 
        {x:477, y:633}, 
        {x:476, y:598}, 
        {x:448, y:577}, 
        {x:427, y:542}, 
        {x:401, y:502}, 
        {x:396, y:458}, 
        {x:392, y:415}, 
        {x:419, y:380}, 
        {x:466, y:338}, 
        {x:514, y:307},
    ];
    var pathpoints = [];
    for(var point of rivercoords){
        pathpoints.push(new Point(point.x, point.y));
    }
    var path = new Path(pathpoints);
    path.smooth();

    let leftriverdefs = [];
    let rightriverdefs = [];

    for(let i = 0; i < 15; i++){
        let offset = (path.length / 15) * i;
        let point = path.getPointAt(offset);

        var newdot = new Path.Circle(point, 3);
        newdot.strokeColor = "black"

        let normvec = path.getNormalAt(offset).multiply(40);
        console.log(`normvec at`);
        console.log(normvec);

        leftriverdefs.push(point.add(normvec));
        rightriverdefs.push(point.subtract(normvec));

        let normvecrep = new Path({segments: [point.subtract(normvec), point.add(normvec)], strokeColor: "red"});

        let textlabel = new PointText(point);
        textlabel.justification = "left"
        textlabel.content = normvec
        textlabel.position += new Point(5, 0)
    }

    var leftriverpath = new Path(leftriverdefs);
    var rightriverpath = new Path(rightriverdefs);

    leftriverpath.strokeColor = "green";
    rightriverpath.strokeColor = "blue";
    leftriverpath.smooth();
    rightriverpath.smooth();

    path.strokeColor = "black";
}

window.onload = function () {
    constructVis();
}
