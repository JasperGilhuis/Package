using ConsoleApp.Package.Enum;

namespace ConsoleApp.Package.Base
{
    public class Animal
    {
        public string Name { get; set; }
        public BloodTypeEnum BloodType { get; set; }
        public Animal(BloodTypeEnum bloodType, string name)
        {
            this.BloodType = bloodType;
            this.Name = name;
        }
        public Animal(BloodTypeEnum bloodType)
        {
            this.BloodType = bloodType;
        }



    }
}
