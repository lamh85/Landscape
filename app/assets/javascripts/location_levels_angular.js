var locationLevelApp = angular.module("locationLevelApp",[]);

locationLevelApp.config([ "$httpProvider", function($httpProvider) {
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

locationLevelController = locationLevelApp.controller("locationLevelController", ['$scope', '$http', function($scope, $http){

    // Model
    // -----

    // DB data
    var levelsRaw = [];
    $scope.levelsSegmented = {};

    var levelModel = function(argObject){
        this.level = argObject.level;
        this.name = "UN-NAMED LEVEL";
        this.thread = argObject.thread;
    }

    // Drag and drop data
    var draggedElement = {};
    var draggedElementData = {};
    var draggedIndex = {};
    var dropElement = {};
    var dropIndex = {};
    var threadAffected = {};

    // Saving Level Name
    // -----------------

    var intervalVar;
    $scope.levelNameStatus = "neutral";

    var initializeInterval = function(){
        $scope.levelNameStatus = "saving";
        intervalVar = setInterval(function(){
            console.log("Time's up!!!");
            clearInterval(intervalVar);
        }, 500);
    }

    // $(document).click(function(){
        // reset interval
    // });

    $scope.updateName = function(level) {
        console.log('testing');
        clearInterval(intervalVar);
        initializeInterval();
    }

    $scope.$watch('levelNameStatus', function(newValue, oldValue){
        if (newValue == "neutral") {
            $('#saving').hide();
        } else if (newValue == "saving") {
            $('#saving').show().text("Currently saving...");
        } else if (newValue == "saved") {
            $('#saving').show().text("Saved!");
        }
    })

    // Initialize data
    // ---------------

    var sortByThread = function(a,b) {
        if (a.thread == b.thread) {
            return 0;
        } else if (a.thread > b.thread) {
            return 1;
        } else {
            return -1;
        }
    }

    var divideLevels = function(){
        var lastThreadNumber = 0;
        while (levelsRaw.length > 0) {
            // If this is a new thread number, then create new property in object
            if (levelsRaw[0].thread != lastThreadNumber) {
                $scope.levelsSegmented["thread" + levelsRaw[0].thread] = [];
                lastThreadNumber = levelsRaw[0].thread;
            }
            $scope.levelsSegmented["thread" + lastThreadNumber].push(levelsRaw[0]);
            levelsRaw.splice(0, 1);
        }
    }

    var sortLevels = function() {
        levelsRaw = levelsRaw.sort(sortByThread);
        divideLevels();
    }

    $http.get('../location_levels/get_all').then(function(response){
        levelsRaw = response.data;
        sortLevels();
    });

    // Drag and drop functions
    // -----------------------

    var getIndex = function(element) {
        return $(element).closest('.level').data('index');
    }

    var shiftArray = function() {
        $scope.levelsSegmented[threadAffected].splice(draggedIndex, 1);
        $scope.levelsSegmented[threadAffected].splice(dropIndex, 0, draggedElementData);
    }

    $scope.handleDrag = function() {
        draggedElement = event.target;
        draggedIndex = getIndex(draggedElement);
        threadAffected = $(event.target).closest('.level').data('thread');
        draggedElementData = $scope.levelsSegmented[threadAffected][draggedIndex];
    }

    $scope.handleDragover = function() {
        dropElement = event.target;
        dropIndex = getIndex(dropElement);
    }

    $scope.handleDrop = function() {
        if (threadAffected == $(dropElement).closest('.level').data('thread')) {
            $scope.levelsSegmented[threadAffected].splice(draggedIndex, 1);
            $scope.levelsSegmented[threadAffected].splice(dropIndex, 0, draggedElementData);
        }
    }

    // Other event listeners
    // ---------------------

    $scope.addLevel = function(params) {
        var newLevel = new levelModel({
            level: params.level,
            thread: params.propertyName.replace(/[^0-9]/gi, "")
        });

        $http.post('../location_levels', newLevel).then(function(response){
            $scope.levelsSegmented[params.propertyName].push(response.data);
        });
    }

    $scope.deleteLevel = function(level, threadAffected) {
        $http.delete('../location_levels/' +level.id).then(function(response){
            if (response.data) {
                $scope.levelsSegmented[threadAffected].splice(
                    $scope.levelsSegmented[threadAffected].indexOf(level), 1
                );
            }
        });
    }

}]); // End controller

locationLevelController.directive('dragDir', function(){
    return {
        scope: {
            dirDragAtt: "&",
            dirDragoverAtt: "&",
            dirDropAtt: "&"
        },
        link: function(scope, element){
            $(element)
                .attr('draggable', 'true')
                .on('dragstart', function(){
                    scope.$apply('dirDragAtt()');
                })
                .on('dragover', function(event){
                    if (event.preventDefault) event.preventDefault();
                    scope.$apply('dirDragoverAtt()');
                    $(event.target).closest('.tag').addClass('dragged-over');
                })
                .on('dragleave', function(event){
                    $(event.target).closest('.tag').removeClass('dragged-over');
                })
                .on('drop', function(event){
                    scope.$apply('dirDropAtt()');
                    $('*').removeClass('dragged-over');
                });
        }
    }
}); // End directive