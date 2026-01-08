window.addEventListener("load", (event) => {
    var packageList = new List(
        "package-list",
        {
            valueNames: [ "package",  "description", "updated" ],
            searchColumns: [ "package", "description" ],
            searchDelay: 500
        }
    );
    packageList.sort("package", { order: "asc" });
});
