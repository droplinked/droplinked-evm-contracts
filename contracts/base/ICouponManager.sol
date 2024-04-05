import "../structs/structs.sol";

interface ICouponManager {
    function addCoupon(
        uint256 _secretHash,
        bool _isPercentage,
        uint256 _value
    ) external;
    function checkAndGetCoupon(CouponProof memory _proof) external view returns (Coupon memory);
    function couponAvailable(uint256 _secretHash) external view returns (bool);
    function coupons(
        uint256
    )
        external
        view
        returns (
            bool isPercentage,
            uint256 value,
            uint256 secretHash,
            address couponProducer
        );
    function getCoupon(uint256 _secretHash) external view returns (Coupon memory);
    function removeCoupon(uint256 secretHash) external;
    function verifyProof(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) external view returns (bool valid);
}
