using System;
using System.IO;
using Xunit;
using RestSharp;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace TestRuntimeImages
{
    public class UnitTest1
    {
        private string GetTargetImageTag(string stack, string version)
        {
            stack = stack.ToLower();
            version = version.ToLower();
            var client = new RestClient("https://testimagepuller.patle15.antares-test.windows-int.net/images");
            client.RemoteCertificateValidationCallback = (sender, certificate, chain, sslPolicyErrors) => true;
            client.Timeout = -1;
            var request = new RestRequest(Method.GET);
            IRestResponse response = client.Execute(request);

            dynamic json = JsonConvert.DeserializeObject(response.Content);
            foreach (dynamic image in json.images)
            {
                if (((JObject)image).HasValues)
                {
                    string repository = image.Repository.Value.ToString().ToLower();
                    string tag = image.Tag.Value.ToString().ToLower();

                    if (repository.Contains(":"))
                    {
                        continue;
                    }

                    if (repository.Contains(stack) && tag.Contains(version))
                    {
                        return string.Format("{0}:{1}", repository, tag);
                    }
                }
            }

            return "";  // not found
            // build tag (use kudulite for build #)
        }

        private static string GetBuildNumber()
        {
            String file = "BuildNumber.txt";
            string BuildNumber = "";
            if (File.Exists(file))
            {
                BuildNumber = File.ReadAllText(file);
            }
            return BuildNumber;
        }

        [Fact]
        public void PHP_HelloWorld()
        {
            // Arrange
            string src = string.Format("appsvctestlinuxci/php:5.6-apache_{0}", GetBuildNumber());
            string target = GetTargetImageTag("php", "7.2");
            string addr = "https://testimagepuller.patle15.antares-test.windows-int.net";
            string url = string.Format("{0}/{1}?source={2}&tag={3}", addr, "pullandtag", target, src);
            var client = new RestClient(url);
            client.RemoteCertificateValidationCallback = (sender, certificate, chain, sslPolicyErrors) => true;
            client.Timeout = -1;
            var request = new RestRequest(Method.GET);
            IRestResponse response = client.Execute(request);
            Console.WriteLine(response.Content);

            // Act

            // git push

            // Assert
            Assert.True(1 == 1);
            // curl
        }
    }
}
